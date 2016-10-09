////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *      DSPresentingEmailReporter.m
 *      DeepStorm Framework
 *
 *      Created by Alexandr Babenko on 27.02.16.
 *      Copyright © 2016 Alexandr Babenko. All rights reserved.
 *
 *      Licensed under the Apache License, Version 2.0 (the "License");
 *      you may not use this file except in compliance with the License.
 *      You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *      Unless required by applicable law or agreed to in writing, software
 *      distributed under the License is distributed on an "AS IS" BASIS,
 *      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *      See the License for the specific language governing permissions and
 *      limitations under the License.
 */
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#import "DSPresentingEmailReporter.h"
#import "UIWindow+DSControllerDetermination.h"
#import "NSString+DSEmailValidation.h"

@import MessageUI;

@interface DSPresentingEmailReporter () <MFMailComposeViewControllerDelegate>

@end

@implementation DSPresentingEmailReporter

#pragma mark - DSEmailReporterProtocol (SENDING Email)

/**
    @abstract Метод отправки имейла с множественными прикрепленными файлами
    @discussion
    Является основным методом репортера, который содержит всю логику отправки  email-письма. Использует стандартный MFMailComposeViewController.
 
    Имеет следующую последовательность выполнения : 
    <ol type="1">
        <li> Проверяет на возможность отсылки письма (настроен ли почтовый клиент, поддерживает ли устройство) </li>
        <li> Формирует и параметризует контроллер (передает destination Email, bodyMessage и пр. ) </li>
        <li> Прикреплят к письму все файлы (поддерживает вроде до 50 или 100 прикрепленных файлов в 1м письме) </li>
        <li> Находит наиболее подходящий view controller для модального отображения, и презентует MFMailComposeViewController </li>
    </ol>
 
    @note Важно, чтобы у пользователя был настроен почтовый клиент по-умолчанию
 
    @warning Позволяет отправлять только  некоторые текстовые файлы (т.к. имеет пока фиксированный MimeType == public.text)
 
    @param filesDictionary       Словарь файлов (имя файла -> данные файла)
 */
- (void)sendEmailWithFileArray:(NSDictionary <NSString*, NSData*> *)filesDictionary{
    
    BOOL canEmailing = [MFMailComposeViewController canSendMail];
    if(! canEmailing){
        NSLog(@"CAN NOT USE EMAIL : Your device doesn't support the composer sheet");
        return;
    }
    
    NSAssert(filesDictionary && filesDictionary.count > 0, @"FILES DICTIONARY Must be not nil");
    
    MFMailComposeViewController *mailController = [MFMailComposeViewController new];
    mailController.mailComposeDelegate = self;
    
    NSString *emailHtmlBodyText = [NSString stringWithFormat:@"ATTACHED %lu REPORT FILE", (unsigned long)filesDictionary.count];
    [mailController setSubject:@"DeepStorm Reporter"];
    [mailController setMessageBody:emailHtmlBodyText isHTML:NO];
    
    NSString *destinationAddress = [self getDestinationEmail];
    if(destinationAddress){
        [mailController setToRecipients:@[destinationAddress]];
    }
    
    // Прикрепляет все файлы к имейлу
    for (NSString *filenameKey in [filesDictionary allKeys]) {
        
        NSData *fileData = filesDictionary[filenameKey];
        [mailController addAttachmentData:fileData mimeType:@"public.text" fileName:filenameKey];
    }
    
    // Чтобы на корректном контроллере модальным представлением MFMailComposeViewController
    id<UIApplicationDelegate> appDelegate = (id<UIApplicationDelegate>)[UIApplication sharedApplication].delegate;
    UIViewController *currentVisibleController = [appDelegate.window visibleViewController];
    
    [currentVisibleController presentViewController:mailController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

/// Метод делегата MFMailComposeViewControllerDelegate, получает результат отправки
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{
    
    switch (result){
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // убираем контроллер после отсылки, и отправляем соответствующий коллбэк по результату
    __weak __block typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        
        __strong __block typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf.reportingCompletion){
            
            switch (result) {
                case MFMailComposeResultSent:
                    strongSelf.reportingCompletion(YES, nil);
                    break;
                case MFMailComposeResultCancelled:
                case MFMailComposeResultSaved:
                    strongSelf.reportingCompletion(NO, nil);
                    break;
                case MFMailComposeResultFailed:
                    strongSelf.reportingCompletion(NO, error);
                    break;
                default:
                    break;
            }
        }
    }];
}

@end
