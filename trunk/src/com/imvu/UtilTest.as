package com.imvu {
 
    import flash.events.*;
    import flash.net.*;
    import com.adobe.serialization.json.JSON;

    public class UtilTest extends ImvuTestCase {

        public function UtilTest(config:Object):void {
            super(config);
        }
        
        public function testAssertValueEquals():void {
            assertValueEquals({},{});
            assertValueEquals({'a':4,'b':6},{'a':4,'b':6});
            assertValueEquals({'a':4,'b':6},{'b':6,'a':4});
        }

        public function testObjectsFromTableConvertsEmptyArray():void {
            assertValueEquals(Util.objectsFromTable({}),[]);
            assertValueEquals(Util.objectsFromTable({'a':[], 'b':[]}),[]);
        }

        public function testObjectsFromTableConvertsSingleRowArray():void {
            assertValueEquals(Util.objectsFromTable({'a':[1]}),[{'a':1}]);
            assertValueEquals(Util.objectsFromTable({'a':[1],'b':[{'name':'john'}]}),
                                                    [{'a':1, 'b':{'name':'john'}}]);
        }

        public function testObjectsFromTableConvertsMultiRowArray():void {
            assertValueEquals(Util.objectsFromTable({'a':[1,2,3]}),[{'a':1},{'a':2},{'a':3}]);
            assertValueEquals(Util.objectsFromTable({'a':[7,8,9],'b':[{'name':'john'},'fred',{'name':'mary'}]}),
                                                    [{'a':7, 'b':{'name':'john'}},
                                                     {'a':8, 'b':'fred'},
                                                     {'a':9, 'b':{'name':'mary'}}]);
        }

        public function testIndexObjectsIndexesEmptyArray():void {
            assertValueEquals(Util.indexObjects([],'id'),{});
            assertValueEquals(Util.indexObjects([{}],'id'),{});
        }

        public function testIndexObjectsIndexesMultiRowArray():void {
            var b = {'id':'b', 'b':{'name':'john'}};
            var d = {'id':'d', 'b':'fred'};
            var f = {'id':'f', 'b':{'name':'mary'}};

            assertValueEquals(
                Util.indexObjects([b, d, f],'id'),
                {'b':b, 'd':d, 'f':f}
            );
        }

        public function notestObjectsFromTableWorksWithProductBatchService():void {

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, addAsync(completeTestObjectsFromTableWorksWithProductBatchService,5000));

            var request:URLRequest = new URLRequest("http://localhost.imvu.com/api/service/product_batch.php");
            request.method = URLRequestMethod.POST;
            request.data = JSON.encode({'product_ids':[80,47550,19746]});
            request.contentType = 'application/json';
            loader.load(request);
        }

        public function completeTestObjectsFromTableWorksWithProductBatchService(event:Event):void {

            var table:Object = JSON.decode(event.target.data);
            var objects:Object = Util.objectsFromTable(table['result']);
            assertEquals(objects.length,3);
            assertEquals(objects[0]['product_id'], 80);
            assertEquals(objects[0]['product_name'], "Female avatar");
            assertEquals(objects[0]['manufacturer_id'], "39");
            assertEquals(objects[0]['product_path'], "108");
            
        }
        
        public function testRemoveDuplicates():void {
            var arr:Array = [1, 2, 3, 1, 2, 3, 3, 2, 1, 6, 4, 1, 4, 6, 5];
            var result:Array = Util.removeDuplicates(arr);
            assertEquals("1,2,3,6,4,5", result.toString());
        }
        
        public function testDeepCompare():void {
            var cmp:Function = Util.deepCompare;
            assertTrue (cmp(1, 1));
            assertFalse(cmp(1, 0));
            assertTrue (cmp("Hello", "Hello"));
            assertFalse(cmp("Hello", "Kitty"));

            assertTrue (cmp([], []));
            assertTrue (cmp([1], [1]));
            assertFalse(cmp([1], []));
            assertFalse(cmp([1], [0]));
            assertTrue (cmp([1, 2], [1, 2]));
            assertFalse(cmp(["Hello", "Kitty"], ["Goodbye", "Kitty"]));
            assertTrue (cmp([1, [2, 3]], [1, [2, 3]]));
            assertFalse(cmp([1, [2, 3]], [1, ["Hello", 3]]));
            assertFalse(cmp([[1, 2], 3], [1, [2, 3]]));

            assertTrue (cmp({1:2}, {1:2}));
            assertFalse(cmp({1:2}, {1:3}));
            assertTrue (cmp({1:2, 3:4}, {3:4, 1:2}));
            assertTrue (cmp([{1:2, 3:4}, {1:3, 2:5}], [{3:4, 1:2}, {2:5, 1:3}]));
            assertFalse(cmp({}, {1:2}));
        }

        public function testArrayColumn() {
            var a = [{a:1, b:2},
                     {a:2, b:3},
                     {a:7, b:1}];

            assertEquivalent([1, 2, 7], Util.arrayColumn(a, 'a'));
            assertEquivalent([2, 3, 1], Util.arrayColumn(a, 'b'));
        }
        
        public function testNavigateToNamedUrl() {
            var ei = new StubExternalInterface();
            var paramsObject:Object = {"something":"something else"};
            
            Util.navigateToNamedUrl(ei, "url name", paramsObject);
            
            assertEquals(ei.calls.length, 1);
            assertEquals(ei.calls[0][0], "launchNamedUrlInBrowser" );
            assertEquals(ei.calls[0][1], "url name" );
            assertEquivalent(ei.calls[0][2], paramsObject);            
        }

        public function testRange() {
            assertEquivalent([0, 1, 2, 3, 4, 5], Util.range(6));
            assertEquivalent([3, 4, 5], Util.range(3, 6));
        }

        public function testIntersection() {
            assertEquivalent([1, "foo", "hork"],
                             Util.intersection([1, 2, "foo", 3, 5, "hork"],
                                               ['hork', 'foo', 'blarg', 1, 'antidisestablishmentarianism']));
        }
    }
}
