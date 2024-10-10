import { Injectable } from '@nestjs/common';
import { SqsMessageHandler } from '@ssut/nestjs-sqs';
import { EmailService } from '../email/email.service';

@Injectable()
export class SqsConsumer {
  constructor(private readonly emailService: EmailService) {}

  @SqsMessageHandler('email-queue', false)
  async handleMessage(message: AWS.SQS.Message) {
    const { recipient, message: emailMessage } = JSON.parse(message.Body);
    await this.emailService.sendEmail(recipient, emailMessage);
  }
}
