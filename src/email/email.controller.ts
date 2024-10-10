import { Controller, Post, Body } from '@nestjs/common';
import { EmailService } from './email.service';

@Controller('email')
export class EmailController {
  constructor(private readonly emailService: EmailService) {}

  @Post()
  async sendEmail(
    @Body('recipient') recipient: string,
    @Body('message') message: string,
  ) {
    return await this.emailService.sendEmail(recipient, message);
  }
}
