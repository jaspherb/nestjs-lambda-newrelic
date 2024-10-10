import { Injectable } from '@nestjs/common';
import * as AWS from 'aws-sdk';

@Injectable()
export class EmailService {
  private ses: AWS.SES;

  constructor() {
    this.ses = new AWS.SES({
      region: 'ap-northeast-1',
      endpoint: 'http://localhost:4566',
    });
  }

  async sendEmail(recipient: string, message: string) {
    const params = {
      Source: 'your-email@example.com',
      Destination: {
        ToAddresses: [recipient],
      },
      Message: {
        Subject: { Data: 'Test Email' },
        Body: { Text: { Data: message } },
      },
    };

    try {
      const result = await this.ses.sendEmail(params).promise();
      console.log('Email sent successfully:', result);
      return result;
    } catch (error) {
      console.error('Error sending email:', error);
      throw error;
    }
  }
}
