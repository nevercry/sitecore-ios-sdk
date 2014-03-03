#import "SCAsyncTestCase.h"

@interface ReadPagingItemsAuthTest : SCAsyncTestCase
@end

@implementation ReadPagingItemsAuthTest

-(void)testPagedItemSCWithoutAuth
{
    __block SCPagedItems* pagedItems_;
    __block SCApiSession* strongContext_  = nil;
    __weak __block SCApiSession* apiContext_ = nil;
    __block NSNumber* items_count_ = 0;

    void (^block_)(JFFSimpleBlock) = ^void( JFFSimpleBlock didFinishCallback_ )
    {
        strongContext_ = [ TestingRequestFactory getNewAnonymousContext ];
        apiContext_ = strongContext_;

        SCReadItemsRequest* request_ = [ SCReadItemsRequest new ];
        request_.requestType = SCReadItemRequestItemPath;
        request_.scope       = SCReadItemSelfScope | SCReadItemChildrenScope;
        request_.request     = SCHomePath;
        request_.fieldNames  = nil;
        request_.pageSize    = 2;

        pagedItems_ = [ SCPagedItems pagedItemsWithApiSession: apiContext_
                                                      request: request_ ];
        [ pagedItems_ itemsTotalCountReader ]( ^( id result_, NSError* error_ )
        {
            items_count_ = result_;
            [ pagedItems_ itemReaderForIndex: 0 ]( ^( id result_, NSError* error_ )
            {
                didFinishCallback_();
            } );
        } );
    };

    [ self performAsyncRequestOnMainThreadWithBlock: block_
                                           selector: _cmd ];

    GHAssertTrue( apiContext_ != nil, @"OK" );
    GHAssertTrue( [ items_count_ unsignedIntValue ] == 4, @"OK" );

    GHAssertTrue( [ pagedItems_ itemForIndex: 0 ] != nil, @"OK" );
    SCItem* parent_ = [ pagedItems_ itemForIndex: 0 ];
    GHAssertTrue( [ parent_.displayName isEqualToString: SCHomeDisplayName ], @"OK" );
    NSDictionary *dic = parent_.allFieldsByName;
    GHAssertTrue( dic != nil, @"OK" );
    GHAssertTrue( [ dic count ] == [ parent_.readFieldsByName count ], @"OK" );

    GHAssertTrue( [ parent_.readChildren count ] == 1, @"OK" );
    GHAssertTrue( parent_.parent == nil, @"OK" );

    GHAssertTrue( [ pagedItems_ itemForIndex: 1 ] != nil, @"OK" );
    SCItem* child_ = [ pagedItems_ itemForIndex: 1 ];
    GHAssertTrue( child_.parent  == parent_, @"OK" );
    GHAssertTrue( child_.readChildren == nil, @"OK" );

    GHAssertTrue( child_.allFieldsByName != nil, @"OK" );
    GHAssertTrue( [ child_.allFieldsByName count ] == [ child_.readFieldsByName count ], @"OK" );
    GHAssertTrue( [ pagedItems_ itemForIndex: 2 ] == nil, @"OK" );
}

@end
