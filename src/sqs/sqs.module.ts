import { Module } from '@nestjs/common';
import { SqsConsumer } from './sqs.consumer';
import { EmailModule } from '../email/email.module';

@Module({
  imports: [EmailModule],
  providers: [SqsConsumer],
})
export class SqsModule {}
