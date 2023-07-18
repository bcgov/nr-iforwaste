//
//  CodeDAO.m
//  WasteMobile
//
//  Created by Jack Wong on 2014-09-17.
//  Copyright (c) 2014 Salus Systems. All rights reserved.
//

#import "CodeDAO.h"
#import "BorderlineCode.h"
#import "ButtEndCode.h"
#import "CommentCode.h"
#import "DecayTypeCode.h"
#import "Constants.h"
#import "ScaleGradeCode.h"
/*
#import "ScaleSpeciesCode.h"
#import "ScaleGradeCode.h"
#import "TopEndCode.h"
#import "CheckerStatusCode.h"
#import "WasteClassCode.h"
#import "MaterialKindCode.h"
#import "WasteLevelCode.h"
#import "ShapeCode.h"
#import "StratumTypeCode.h"
#import "HarvestMethodCode.h"
#import "PlotSizeCode.h"
#import "ConditionCode.h"
#import "DesignationTypeCode.h"
#import "SnowCode.h"
#import "MaturityCode.h"
#import "MaterialKindCode.h"
#import "ReasonCode.h"
#import "RoleTypeCode.h"
*/

@implementation CodeDAO {
    NSDictionary *codeDictionary;
}

+(CodeDAO *)sharedInstance{
    static CodeDAO *singletonCodeDAO = nil;

    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        singletonCodeDAO = [[super alloc] init];
    });
    
    return singletonCodeDAO;
}

- (id)init {
    self = [super init];

    if(self){
        //custom initialization
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BorderlineCode"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        if(error != nil){
            NSLog(@"Error when checking the existence of code table: %@", error);
        }else{
            if([fetchedObjects count] == 0){
                [self initCodeTable:&error];

                if ( error != nil){
                    NSLog(@"Error when initializing the code table data: %@", error);
                }
            }else{
                [self initCodeDictionary];
            }
        }
    }
    return self;
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]){
        context = [delegate managedObjectContext];
    }
    return context;
}

// codeName - eg maturityCode, snowCode
-(NSManagedObject *) getCodeByNameCode:(NSString *)codeName code:(NSString *)code{
    //NSLog(@"Search for codeName:%@ and code:%@", codeName, code );

    NSString *codeKey =[[[codeName substringToIndex:1] uppercaseString] stringByAppendingString:[codeName substringFromIndex:1]];
    for (NSManagedObject *codeObj in [codeDictionary objectForKey:codeKey]){
        if ([[codeObj valueForKey:codeName] isEqualToString:code]){
            //NSLog(@"Code found!");
            return codeObj;
        }
    }
    
    //NSLog(@"Code NOT found!");
    return nil;
}


-(void) initCodeDictionary{
    if (codeDictionary == nil){
        NSMutableArray *codeNameAry = [[NSMutableArray alloc] init];
        [codeNameAry addObject:@"BorderlineCode"];
        [codeNameAry addObject:@"ButtEndCode"];
        [codeNameAry addObject:@"CommentCode"];
        [codeNameAry addObject:@"DecayTypeCode"];
        [codeNameAry addObject:@"ScaleSpeciesCode"];
        [codeNameAry addObject:@"ScaleGradeCode"];
        [codeNameAry addObject:@"TopEndCode"];
        [codeNameAry addObject:@"CheckerStatusCode"];
        [codeNameAry addObject:@"WasteClassCode"];
        [codeNameAry addObject:@"MaterialKindCode"];
        [codeNameAry addObject:@"WasteLevelCode"];
        [codeNameAry addObject:@"WasteTypeCode"];
        [codeNameAry addObject:@"ShapeCode"];
        [codeNameAry addObject:@"StratumTypeCode"];
        [codeNameAry addObject:@"HarvestMethodCode"];
        [codeNameAry addObject:@"PlotSizeCode"];
        [codeNameAry addObject:@"SnowCode"];
        [codeNameAry addObject:@"MaturityCode"];
        [codeNameAry addObject:@"MonetaryReductionFactorCode"];
        [codeNameAry addObject:@"AssessmentMethodCode"];
        [codeNameAry addObject:@"SiteCode"];
    
    
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        NSMutableArray *singleCodeAry = [[NSMutableArray alloc] init];
        NSMutableArray *store2DCodeAry = [[NSMutableArray alloc] init];
        
        for (NSString *code in codeNameAry){
        
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:code
                                                  inManagedObjectContext:context];
            [fetchRequest setEntity:entity];

            NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

            if(error != nil){
                NSLog(@"Error when checking the existence of code table: %@", error);
            }else{
                if([fetchedObjects count] != 0){
                    for( NSManagedObject *obj in fetchedObjects){
                        [singleCodeAry addObject:obj];
                    }
                    [store2DCodeAry addObject:singleCodeAry];
                    singleCodeAry = [[NSMutableArray alloc] init];
                }
            }

        }
        codeDictionary = [[NSDictionary alloc] initWithObjects:store2DCodeAry forKeys:codeNameAry];
      
    }

}

-(void) initCodeTable:(NSError **)error{
    if (codeDictionary == nil){
        NSMutableArray *codeAry = [[NSMutableArray alloc] init];
        //hardcode all the code here and use for loop to populate them into core data
        //index 0 : code name
        //index 1 : code property name
        //index 2 : code
        //index 3 : description
        //index 4 : effective date (day/month/year)
        //index 5 : expiry date (day/month/year)
        //index 6 : update timestamp (day/month/year)
        //index 7 : survey type code (only for ScaleSpeciesCode and ScaleGradeCode)
        //index 8 : area type code for scale grade code, plot multipler for plot size code
        
        //borderline code
        [codeAry addObject:@"BorderlineCode;borderlineCode;I;Completely inside plot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"BorderlineCode;borderlineCode;B;Borderline piece (measure inside portion only);1/9/2014;;1/9/2014;"];
        //[codeAry addObject:@"BorderlineCode;borderlineCode;X;Length exceeds plot width;1/9/2014;;1/9/2014;"];

        //butt end code
        [codeAry addObject:@"ButtEndCode;buttEndCode; ;None;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ButtEndCode;buttEndCode;B;Broken;1/9/2014;;1/9/2014;;"];
        //[codeAry addObject:@"ButtEndCode;buttEndCode;P;Pencil;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ButtEndCode;buttEndCode;C;Cut bucked;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ButtEndCode;buttEndCode;U;Undercut;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ButtEndCode;buttEndCode;N;Natural;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ButtEndCode;buttEndCode;X;Buried;1/9/2014;;1/9/2014;"];
        
        //comment code
        [codeAry addObject:@"CommentCode;commentCode; ;None ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;BK;Breakage ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;BN;Bunch knots ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;BR;Buried ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;CA;Candlelabra ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;CC;Creek cleaning ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;CF;Catface ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;CK;Crook ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;CL;Culvert log ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;CP;Company piece ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;CR;Severe Crook ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;DP;Dead potential ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;DU;Dead useless ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;FC;Frostcrack ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;FK;Fork ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;FL;Fluted Butt (NOT IN XML) ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;FP;Fence post ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;FW;Firewood ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;GL;Guyline stump ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;HK;Hooked ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;HN;Heavy knots ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;HP;Helipad ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;HS;Holding stump ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;IN;Inaccessable ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;KN;Knots ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;LB;Long butt ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;LN;Large knots ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;MB;Machine breakage ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;MP;Multiple part piece ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;NP;Nil plot ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;OB;Obstructed ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;ON;Oversize knots ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;PR;Pocket rot ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;RE;Reconstructed ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;S1;Segment 1 ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;S2;Segment 2 ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;S3;Segment 3 ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;SA;Sapling ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;SB;Shake block ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;SH;Shatter ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;SL;Slab ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;ST;Standing tree ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;SW;Sweep ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;TR;Whole tree ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;US;Unsafe ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;WD;Coarse woody debris ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;WF;Windfall ;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CommentCode;commentCode;WS;Windshear;1/9/2014;;1/9/2014;"];
        
        //decay code
        [codeAry addObject:@"DecayTypeCode;decayTypeCode; ;None;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"DecayTypeCode;decayTypeCode;B;Butt rot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"DecayTypeCode;decayTypeCode;C;Conk rot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"DecayTypeCode;decayTypeCode;H;Heart rot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"DecayTypeCode;decayTypeCode;P;Pocket rot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"DecayTypeCode;decayTypeCode;R;Ring rot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"DecayTypeCode;decayTypeCode;S;Sap rot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"DecayTypeCode;decayTypeCode;T;Top rot;1/9/2014;;1/9/2014;"];
        
        //scale species code [note: miss survey type?]
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;AL;Alder;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;AR;Arbutus;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;AS;Aspen;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;BA;Balsam;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;BI;Birch;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;CE;Red Cedar;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;CO;Cottonwood;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;CY;Cypress;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;FI;Douglas Fir;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;HE;Hemlock;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;LA;Larch;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;LO;Lodgepole Pine;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;MA;Maple;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;OT;Other (Cherry);1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;SP;Spruce;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;WB;Whitebark Pine;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;WH;White Pine;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;WI;Willow;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;UU;Pacific Yew;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ScaleSpeciesCode;scaleSpeciesCode;YE;Yellow Pine;1/9/2014;;1/9/2014;"];
        
        //scale grade code
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;B;Peeler;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;C;Peeler;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;D;Lumber;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;F;Lumber;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;H;Sawlog;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;I;Sawlog;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;J;Gang Sawlog;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;K;Cedar Shingle;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;L;Cedar Shingle;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;M;Cedar Shingle;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;U;Utility Sawlog;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;W;Deciduous Sawlog;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;X;Chipper;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;Y;Lumber reject;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;Z;Firmwood reject;1/9/2014;;1/9/2014;;C"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;5;Dead dry lumber reject;1/9/2014;;1/9/2014;;I"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;1;Premium Sawlog;1/9/2014;;1/9/2014;;I"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;2;Sawlog;1/9/2014;;1/9/2014;;I"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;4;Lumber Reject;1/9/2014;;1/9/2014;;I"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;6;Undersize;1/9/2014;;1/9/2014;;I"];
        [codeAry addObject:@"ScaleGradeCode;scaleGradeCode;Z;Firmwood reject;1/9/2014;;1/9/2014;;I"];

        //top end code
        [codeAry addObject:@"TopEndCode;topEndCode; ;None;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"TopEndCode;topEndCode;B;Broken;1/9/2014;;1/9/2014;"];
        //[codeAry addObject:@"TopEndCode;topEndCode;P;Pencil;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"TopEndCode;topEndCode;C;Cut (bucked);1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"TopEndCode;topEndCode;U;Undercut;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"TopEndCode;topEndCode;N;Natural;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"TopEndCode;topEndCode;X;Buried;1/9/2014;;1/9/2014;"];
        
        //checker status code
        [codeAry addObject:@"CheckerStatusCode;checkerStatusCode;1;Not Checked;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CheckerStatusCode;checkerStatusCode;2;Approve;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CheckerStatusCode;checkerStatusCode;3;No Tally;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"CheckerStatusCode;checkerStatusCode;4;Edit Piece;1/9/2014;;1/9/2014;"];

        //waste class code
        [codeAry addObject:@"WasteClassCode;wasteClassCode;A;Avoidable;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteClassCode;wasteClassCode;U;Unavoidable;1/9/2014;;1/9/2014;"];

        //material kind code
        [codeAry addObject:@"MaterialKindCode;materialKindCode;B;Breakage;6/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaterialKindCode;materialKindCode;L;Log, slab. Sliver, chunk;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaterialKindCode;materialKindCode;D;Down tree/snag;7/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaterialKindCode;materialKindCode;S;Stump;3/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaterialKindCode;materialKindCode;T;Tree/snag;4/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaterialKindCode;materialKindCode;U;Undersize;8/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaterialKindCode;materialKindCode;W;Bucking / trimming waste;2/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaterialKindCode;materialKindCode;X;Special Product;5/9/2014;;1/9/2014;"];

        //waste level code
        [codeAry addObject:@"WasteLevelCode;wasteLevelCode;L;Light;3/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteLevelCode;wasteLevelCode;M;Medium;4/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteLevelCode;wasteLevelCode;H;Heavy;2/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteLevelCode;wasteLevelCode;X;Unstratified;1/9/2014;;1/9/2014;"];

        //shape code
        [codeAry addObject:@"ShapeCode;shapeCode;C;Circular;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ShapeCode;shapeCode;S;Square;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ShapeCode;shapeCode;R;Rectangular;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"ShapeCode;shapeCode;X;100% scale;1/9/2014;;1/9/2014;"];
        
        //stratum type code
        [codeAry addObject:@"StratumTypeCode;stratumTypeCode;A;Accumulation;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"StratumTypeCode;stratumTypeCode;D;Dispersed;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"StratumTypeCode;stratumTypeCode;S;Standing;1/9/2014;;1/9/2014;"];

        //harvest method code
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;S;Spar (high lead);5/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;G;Grapple Yarder;4/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;T;Tractor (cat);3/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;P;Horse;8/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;R;Rubber-tired skidder;2/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;M;Hand logging;9/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;B;Hoe chucking;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;H;Helicopter;7/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;W;Wyssen;10/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;O;Other;11/9/2014;;1/9/2014;"];
        [codeAry addObject:@"HarvestMethodCode;harvestMethodCode;C;Any Combination;6/9/2014;;1/9/2014;"];

        //assesssment method code
        [codeAry addObject:@"AssessmentMethodCode;assessmentMethodCode;E;Percent Estimate;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"AssessmentMethodCode;assessmentMethodCode;O;Ocular Estimate;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"AssessmentMethodCode;assessmentMethodCode;P;Plot;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"AssessmentMethodCode;assessmentMethodCode;S;100 Percent Scale;1/9/2014;;1/9/2014;"];

        //plot size code
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;O;Ocular Estimate;6/9/2014;;1/9/2014;;"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;E;Estimate Percent;4/9/2014;;1/9/2014;;"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;S;100% Scale;5/9/2014;;1/9/2014;;"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;0;50 m\u00B2;2/9/2014;;1/9/2014;;50"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;1;100 m\u00B2;7/9/2014;;1/9/2014;;100"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;2;200 m\u00B2;1/9/2014;;1/9/2014;;200"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;3;300 m\u00B2;8/9/2014;;1/9/2014;;300"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;4;400 m\u00B2;3/9/2014;;1/9/2014;;400"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;5;500 m\u00B2;9/9/2014;;1/9/2014;;500"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;6;600 m\u00B2;10/9/2014;;1/9/2014;;600"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;7;1000 m\u00B2;11/9/2014;;1/9/2014;;1000"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;8;5000 m\u00B2;12/9/2014;;1/9/2014;;5000"];
        [codeAry addObject:@"PlotSizeCode;plotSizeCode;9;10000 m\u00B2;13/9/2014;;1/9/2014;;10000"];
        
        //waste type code
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;S;Open Slash/Clearcut;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;F;Felled and bucked;9/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;G;Group retention;10/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;D;Dispersed retention;11/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;T;Standing Stem;5/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;L;Landings;8/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;R;Roadside;4/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;W;Windrow, Debuilt Road;6/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;C;Cold Decked;3/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;P;Spot accumulation;2/9/2014;;1/9/2014;"];
        [codeAry addObject:@"WasteTypeCode;wasteTypeCode;O;Off-site landing;7/9/2014;;1/9/2014;"];
        
        //snow code
        [codeAry addObject:@"SnowCode;snowCode;Y;Yes;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"SnowCode;snowCode;N;No;1/9/2014;;1/9/2014;"];
        
        //maturity code
        [codeAry addObject:@"MaturityCode;maturityCode;M;Greater than 8R;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MaturityCode;maturityCode;I;Top greater than 5R;2/9/2014;;1/9/2014;"];
        
        //*** add site code as part of the maturity code
        [codeAry addObject:@"SiteCode;siteCode;DB;Dry Belt;3/9/2014;;1/9/2014;"];
        [codeAry addObject:@"SiteCode;siteCode;TZ;Transition Zone;4/9/2014;;1/9/2014;"];
        [codeAry addObject:@"SiteCode;siteCode;WB;Wet Belt;5/9/2014;;1/9/2014;"];

        //monetary reducton factor code
        [codeAry addObject:@"MonetaryReductionFactorCode;monetaryReductionFactorCode;A;Benchmark Applied;1/9/2014;;1/9/2014;"];
        [codeAry addObject:@"MonetaryReductionFactorCode;monetaryReductionFactorCode;B;Benchmark Not Applied;1/9/2014;;1/9/2014;"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"d/L/yyyy"];
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSString *codeName = @"";
        
        NSMutableArray *singleCodeAry = nil;
        NSMutableArray *codeNameKey = [[NSMutableArray alloc] init];
        NSMutableArray *store2DCodeAry = [[NSMutableArray alloc] init];
        
        for (NSString *codeEntry in codeAry){
            NSArray *codeDetailAry = [codeEntry componentsSeparatedByString:@";"];

            if (![[codeDetailAry objectAtIndex:0] isEqualToString:codeName]){
                if(![codeName isEqualToString:@""]){
                    //put the code name and the array for single code to the special array
                    //the arrays to create the distionary later
                    [codeNameKey addObject:codeName];
                    [store2DCodeAry addObject:singleCodeAry];
                }
                
                codeName = [codeDetailAry objectAtIndex:0];
                singleCodeAry = [[NSMutableArray alloc] init];
            }

            NSManagedObject *codeObject =[NSEntityDescription insertNewObjectForEntityForName:[codeDetailAry objectAtIndex:0] inManagedObjectContext:context];
            
            [codeObject  setValue:[codeDetailAry objectAtIndex:2] forKey:[codeDetailAry objectAtIndex:1]];
            [codeObject  setValue:[codeDetailAry objectAtIndex:3] forKey:@"desc"];
            if(![[codeDetailAry objectAtIndex:4] isEqualToString:@""]){
                [codeObject  setValue:[dateFormat dateFromString:[codeDetailAry objectAtIndex:4]] forKey:@"effectiveDate"];
            }
            if(![[codeDetailAry objectAtIndex:5] isEqualToString:@""]){
                [codeObject  setValue:[dateFormat dateFromString:[codeDetailAry objectAtIndex:5]] forKey:@"expiryDate"];
            }
            if(![[codeDetailAry objectAtIndex:6] isEqualToString:@""]){
                [codeObject  setValue:[dateFormat dateFromString:[codeDetailAry objectAtIndex:6]] forKey:@"updateTimestamp"];
            }
            if ([codeDetailAry count] >7){
                if(![[codeDetailAry objectAtIndex:7] isEqualToString:@""]){
                    [codeObject  setValue:[codeDetailAry objectAtIndex:7] forKey:@"surveyType"];
                }
            }
            if([codeDetailAry count] > 8){
                if ([codeName isEqualToString:@"ScaleGradeCode"]){
                    if(![[codeDetailAry objectAtIndex:8] isEqualToString:@""]){
                        [codeObject  setValue:[codeDetailAry objectAtIndex:8] forKey:@"areaType"];
                    }
                }else if([codeName isEqualToString:@"PlotSizeCode"]){
                    if(![[codeDetailAry objectAtIndex:8] isEqualToString:@""]){
                        NSDecimalNumber *pm = [[NSDecimalNumber alloc] initWithFloat:10000.0f/[[codeDetailAry objectAtIndex:8] floatValue]];
                        [codeObject  setValue:pm forKey:@"plotMultipler"];
                    }
                }
            }
            
            [singleCodeAry addObject: codeObject];
        }
        
        [codeNameKey addObject:codeName];
        [store2DCodeAry addObject:singleCodeAry];

        codeDictionary = [[NSDictionary alloc] initWithObjects:store2DCodeAry forKeys:codeNameKey];

        [context save:error];
        
        
    }

}

-(void)refreshCodeTable{
    codeDictionary = nil;
    [self initCodeDictionary];
}

-(NSArray*) getBorderLineCodeList{
    return [codeDictionary objectForKey:@"BorderlineCode"];
}

-(NSArray *) getButtEndCodeList{
    return [codeDictionary objectForKey:@"ButtEndCode"];
}

-(NSArray *) getCommentCodeList{
    return [codeDictionary objectForKey:@"CommentCode"];
}

-(NSArray *) getDecayTypeCodeList{
    return [codeDictionary objectForKey:@"DecayTypeCode"];;
}

-(NSArray *) getScaleSpeciesCodeList{
    return [codeDictionary objectForKey:@"ScaleSpeciesCode"];
}

-(NSArray *) getSnowCodeList{
    return [codeDictionary objectForKey:@"SnowCode"];
}

-(NSArray *) getSurveyReasonCodeList{
    return [codeDictionary objectForKey:@"ReasonCode"];
}

-(NSArray *) getPlotSizeCodeList{
    return [codeDictionary objectForKey:@"PlotSizeCode"];
}

-(NSArray *) getShapeCodeList{
    return [codeDictionary objectForKey:@"ShapeCode"];
}

-(NSArray *) getStratumTypeCodeList{
    return [codeDictionary objectForKey:@"StratumTypeCode"];
}

-(NSArray *) getHarvestMethodCodeList{
    return [codeDictionary objectForKey:@"HarvestMethodCode"];
}

-(NSArray *) getWasteLevelCodeList{
    return [codeDictionary objectForKey:@"WasteLevelCode"];
}

-(NSArray *) getMaturityCodeList{
    return [codeDictionary objectForKey:@"MaturityCode"];
}

-(NSArray *) getMonetaryReductionFactorCodeList{
    return [codeDictionary objectForKey:@"MonetaryReductionFactorCode"];
}

-(NSArray *) getMaterialKindCodeList{
    return [codeDictionary objectForKey:@"MaterialKindCode"];
}

-(NSArray *) getWasteClassCodeList{
    return [codeDictionary objectForKey:@"WasteClassCode"];
}

-(NSArray *) getTopEndCodeList{
    return [codeDictionary objectForKey:@"TopEndCode"];
}

-(NSArray *) getScaleGradeCodeList:(int)regionId{
    //filter the grade code by region
    NSMutableArray *tmpGradeCodes = [[NSMutableArray alloc] init];
    for(ScaleGradeCode *sgc in [codeDictionary objectForKey:@"ScaleGradeCode"]){
        if(regionId== CoastRegion && [sgc.areaType isEqualToString:@"C"]){
            [tmpGradeCodes addObject:sgc];
        }else if(regionId == InteriorRegion && [sgc.areaType isEqualToString:@"I"]){
            [tmpGradeCodes addObject:sgc];
        }
    }
    return [tmpGradeCodes copy];
}

-(NSArray *) getWasteTypeCodeList{
    return [codeDictionary objectForKey:@"WasteTypeCode"];
}

-(NSArray *) getAssessmentMethodCodeList{
    return [codeDictionary objectForKey:@"AssessmentMethodCode"];
}

-(NSArray *) getSiteCodeList{
    return [codeDictionary objectForKey:@"SiteCode"];
}



@end
