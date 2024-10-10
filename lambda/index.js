import { SES } from 'aws-sdk';
const ses = new SES({
  region: 'ap-northeast-1',
  endpoint: 'http://localhost:4566',
});

export async function handler(event) {
  for (const record of event.Records) {
    const { recipient, message } = JSON.parse(record.body);

    const emailParams = {
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
      const result = await ses.sendEmail(emailParams).promise();
      console.log('Email sent successfully:', result);
    } catch (error) {
      console.error('Error sending email:', error);
    }
  }
}
