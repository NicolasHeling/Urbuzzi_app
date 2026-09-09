export class CreateVisitScheduleDto {
  customerName: string;
  date: string | Date;
  responsibleUserName?: string;
  lotId?: string;
}

export class UpdateVisitScheduleDto {
  customerName?: string;
  date?: string | Date;
  responsibleUserName?: string;
  lotId?: string;
}
