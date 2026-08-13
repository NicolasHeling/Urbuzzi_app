import { Module } from '@nestjs/common';
import { CoreProxyController } from './core-proxy.controller';

@Module({
  controllers: [CoreProxyController],
})
export class CoreProxyModule {}
