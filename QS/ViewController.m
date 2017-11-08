#import "ViewController.h"
#import "APIClient.h"

@interface ViewController ()

@property (nonatomic, strong) APIClient *apiClient;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (IBAction)tapDiscreteEvent:(UIButton *)sender {
    if (!self.apiClient) {
        self.apiClient = [[APIClient alloc] init];
    }

    [self.activityIndicator startAnimating];
    [self.apiClient submitDiscreteEvent:[NSDate date] ofType:sender.tag withURI:NULL andMetadata:NULL completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        [self.activityIndicator stopAnimating];
        if (response.statusCode != 201) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't submit event" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
