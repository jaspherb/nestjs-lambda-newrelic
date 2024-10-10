import { Module } from '@nestjs/common';
import { EmailModule } from './email/email.module';
import { SqsModule } from 'src/sqs/sqs.module';

@Module({
  imports: [EmailModule, SqsModule],
})
export class AppModule {}
