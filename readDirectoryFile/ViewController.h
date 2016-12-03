//
//  ViewController.h
//  readDirectoryFile
//
//  Created by xy on 16/9/23.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *txtPath;//文件路径
@property (weak) IBOutlet NSScrollView *iTableView;
@property (weak) IBOutlet NSTextField *txtContent;//文件名
@property (weak) IBOutlet NSTextField *txtFilePath;//文件完整路径
@property (weak) IBOutlet NSScrollView *txtAttributes;//文件属性
@property (weak) IBOutlet NSTextField *lblCount;//文件夹中文件数量

@end

