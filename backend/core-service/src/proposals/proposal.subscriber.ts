import { EventSubscriber, EntitySubscriberInterface, UpdateEvent } from 'typeorm';
import { Proposal } from './proposal.entity';
import { ProposalHistory } from './proposal-history.entity';
import { KanbanColumn } from '../kanban/kanban-column.entity';

@EventSubscriber()
export class ProposalSubscriber implements EntitySubscriberInterface<Proposal> {
  listenTo() {
    return Proposal;
  }

  async afterUpdate(event: UpdateEvent<Proposal>) {
    // If the kanbanColumn property or relation was updated
    const updatedKanbanColumn = event.updatedColumns.find(
      (col) => col.propertyName === 'kanbanColumn' || col.databaseName === 'kanban_column_id',
    ) || event.updatedRelations.find((rel) => rel.propertyName === 'kanbanColumn');

    // Also check if kanbanColumn is present in event.entity to detect changes even if TypeORM relations are tricky
    const hasKanbanColumnEntityUpdate = event.entity && 'kanbanColumn' in event.entity;

    if (updatedKanbanColumn || hasKanbanColumnEntityUpdate) {
      const oldProposal = event.databaseEntity;
      const newProposal = event.entity as Proposal;

      if (!newProposal) return;

      const oldColumnId = oldProposal?.kanbanColumn?.id || oldProposal?.['kanban_column_id'];
      
      let newColumnId = null;
      if (newProposal.kanbanColumn) {
        newColumnId = (newProposal.kanbanColumn as any).id || newProposal.kanbanColumn;
      }

      // If no actual change in ID, ignore
      if (oldColumnId === newColumnId) {
        return;
      }

      // We need to find column names
      let oldColumnName = null;
      let newColumnName = null;

      if (oldColumnId) {
        const oldCol = await event.manager.findOne(KanbanColumn, { where: { id: oldColumnId } });
        if (oldCol) oldColumnName = oldCol.name;
      }

      if (newColumnId) {
        const newCol = await event.manager.findOne(KanbanColumn, { where: { id: newColumnId } });
        if (newCol) newColumnName = newCol.name;
      }

      // Insert history record
      const history = event.manager.create(ProposalHistory, {
        proposalId: newProposal.id,
        oldColumnId,
        oldColumnName,
        newColumnId,
        newColumnName,
        responsibleUserName: newProposal.responsibleUserName || (oldProposal && oldProposal.responsibleUserName) || 'Sistema',
      });

      await event.manager.save(history);
    }
  }
}
