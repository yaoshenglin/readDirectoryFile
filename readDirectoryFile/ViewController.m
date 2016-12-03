//
//  ViewController.m
//  readDirectoryFile
//
//  Created by xy on 16/9/23.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSTextFieldDelegate,NSTableViewDelegate,NSTableViewDataSource,NSOpenSavePanelDelegate>
{
    NSArray *listDir;
    NSString *directoryPath;
    NSTableView *myTableView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubViews];
    // Do any additional setup after loading the view.
}

- (void)setupSubViews
{
    _txtPath.delegate = self;
    _txtContent.editable = NO;
    NSString *path = [@"~" stringByExpandingTildeInPath];
    _txtFilePath.stringValue = path;
    directoryPath = path;
    listDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    myTableView = _iTableView.documentView;
    
    NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@"column1"];
    [column1.headerCell setTitle:@"name"];
    column1.width = 250;
    [myTableView addTableColumn:column1];
    
    NSLog(@"%ld",myTableView.numberOfColumns);
}

- (IBAction)selectFile:(NSButton *)sender
{
    //选择文件
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.delegate = self;
    [panel runModal];
}

- (IBAction)readDirectory:(NSButton *)sender
{
    //读取文件夹内容或者文件属性
    NSString *path = _txtPath.stringValue;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            directoryPath = path;
            listDir = [fileManager contentsOfDirectoryAtPath:path error:nil];
            [myTableView reloadData];
        }else{
            NSString *fileName = path.lastPathComponent;
            _txtContent.stringValue = fileName;
            [self readFileAttributes:path];
        }
    }else{
        NSError *error = nil;
        if ([fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
            if ([fileManager removeItemAtPath:path error:&error]) {
                error = [NSError errorWithDomain:@"该路径不存在" code:201 userInfo:@{}];
            }else{
                error = [NSError errorWithDomain:@"Unknow error" code:202 userInfo:@{}];
            }
        }else{
            error = [NSError errorWithDomain:@"该路径不合法" code:203 userInfo:@{}];
        }
        
        [self showAlertWithError:error];
    }
}

- (IBAction)BackSpace:(NSButton *)sender
{
    NSLog(@"%@",directoryPath);
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [directoryPath stringByDeletingLastPathComponent];
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            listDir = [fileManager contentsOfDirectoryAtPath:path error:nil];
            [myTableView reloadData];
        }
        
        directoryPath = path;
        _txtFilePath.stringValue = path;
    }
}

- (void)showAlertWithError:(NSError *)error
{
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert addButtonWithTitle:@"确定"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        //NSLog(@"%ld",(long)returnCode);
    }];
}

#pragma mark - --------NSTableView------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger rowCount = listDir.count;
    _lblCount.stringValue = [NSString stringWithFormat:@"共%ld个文件",(long)rowCount];
    return rowCount;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.0f;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextFieldCell *textCell = [tableColumn dataCellForRow:row];
    if (!textCell) {
        textCell = [[NSTextFieldCell alloc] initTextCell:@"cell"];
        textCell.importsGraphics = YES;
        textCell.allowsEditingTextAttributes = YES;
    }
    
    if (!textCell.menu) {
        NSMenu *newMenu = [[NSMenu alloc] init];
        NSMenuItem *openItem = [[NSMenuItem alloc] initWithTitle:@"Open" action:@selector(openFile:) keyEquivalent:@""];
        openItem.target = self;
        [newMenu addItem:openItem];
        
        NSMenuItem *deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteFile:) keyEquivalent:@""];
        deleteItem.target = self;
        [newMenu addItem:deleteItem];
        
        [textCell setMenu:newMenu];
        textCell.menu = newMenu;
    }
    
    if (listDir.count > row) {
        NSString *title = [listDir objectAtIndex:row];
        textCell.title = title;
    }else{
        NSLog(@"%ld,%ld",listDir.count,row);
    }
    
    return textCell;///Volumes/Apple/下载
}

//- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSString *identifier = [tableColumn identifier];
//    NSTextFieldCell *textCell = cell;
//    textCell.allowsEditingTextAttributes = YES;
//    NSString *title = [listDir objectAtIndex:row];
//    [textCell setTitle:title];
//    if ([identifier isEqualToString:@"name"]) {
//        [textCell setTitle:@"A"];
//    }
//    else if ([identifier isEqualToString:@"id"])
//    {
//        [textCell setTitle:@"B"];
//    }
//}

//- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    NSCell *cell = (NSCell *)[tableView viewAtColumn:0 row:row makeIfNecessary:YES];
//    if (!cell) {
//        cell = [[NSCell alloc] initTextCell:@"cell"];
//    }
//    return cell;
//}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSString *title = [listDir objectAtIndex:row];
    _txtContent.stringValue = title;
    _txtFilePath.stringValue = [directoryPath stringByAppendingPathComponent:title];
    [self readFileAttributes:_txtFilePath.stringValue];
    NSLog(@"%@",title);
    
    return YES;
}

- (void)readFileAttributes:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSTextView *textView =  _txtAttributes.documentView;
        NSString *content = @"";
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        if (image) {
            NSBitmapImageRep *raw_img = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
            content = [content stringByAppendingFormat:@"width:%.2f\nheight:%.2f\n",image.size.width,image.size.height];
            content = [content stringByAppendingFormat:@"pixelsWide:%ld\npixelsHigh:%ld\n",raw_img.pixelsWide,raw_img.pixelsHigh];
        }
        NSError *error = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
        NSString *desc = fileAttributes.description;
        const char *cString = [desc cStringUsingEncoding:NSUTF8StringEncoding];
        desc = [NSString stringWithCString:cString encoding:NSNonLossyASCIIStringEncoding];
        content = [content stringByAppendingString:desc];
        textView.string = content;
    }
}

#pragma mark - --------右键菜单事件回调------------------------
- (void)openFile:(NSMenuItem *)menuItem
{
    NSInteger row = myTableView.clickedRow;
    NSString *title = [listDir objectAtIndex:row];
    NSString *path = [directoryPath stringByAppendingPathComponent:title];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            directoryPath = path;
            listDir = [fileManager contentsOfDirectoryAtPath:path error:nil];
            [myTableView reloadData];
        }else{
            [[NSWorkspace sharedWorkspace] openFile:path];
        }
        
        _txtFilePath.stringValue = path;
    }
    NSLog(@"打开文件,%@",path);
}

- (void)deleteFile:(NSMenuItem *)menuItem
{
    NSInteger row = myTableView.clickedRow;
    NSString *title = [listDir objectAtIndex:row];
    NSString *path = [directoryPath stringByAppendingPathComponent:title];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        NSError *error = nil;
        if ([fileManager removeItemAtPath:path error:&error]) {
            NSLog(@"%@删除成功",title);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
            [myTableView beginUpdates];
            [myTableView removeRowsAtIndexes:indexSet withAnimation:NSTableViewAnimationSlideLeft];
            [myTableView endUpdates];
            
            NSMutableArray *list = [listDir mutableCopy];
            [list removeObjectsAtIndexes:indexSet];
            listDir = [NSArray arrayWithArray:list];
        }else{
            [self showAlertWithError:error];
        }
    }
}

#pragma mark - --------选择文件事件回调------------------------
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    //将要选择的文件
    //NSLog(@"shouldEnableURL,%@",url.path);
    return YES;
}


- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    //选定后并点击打开的文件
    NSString *urlString = url.path;
    _txtPath.stringValue = urlString;
    _txtFilePath.stringValue = urlString;
    directoryPath = [urlString stringByDeletingLastPathComponent];
    listDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    [myTableView reloadData];
    NSLog(@"validateURL,%@",urlString);
    return YES;
}


- (void)panel:(id)sender didChangeToDirectoryURL:(nullable NSURL *)url
{
    //改变文件夹时的回调
    //NSLog(@"didChangeToDirectoryURL,%@",url.path);
}


- (nullable NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag;
{
    NSLog(@"userEnteredFilename,%@",filename);
    return filename;
}

- (void)panel:(id)sender willExpand:(BOOL)expanding;
{
    NSLog(@"willExpand,%@",sender);
}

- (void)panelSelectionDidChange:(nullable id)sender;
{
    //选中的目标已经改变时的回调
    //NSLog(@"panelSelectionDidChange,%@",sender);
}

#pragma mark -
- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
