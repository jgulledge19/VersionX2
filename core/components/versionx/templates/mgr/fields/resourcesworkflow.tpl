<script type="text/javascript">
var wkCmp = function(config) {
    config = config || {};
    wkCmp.superclass.constructor.call(this,config);
};
Ext.extend(wkCmp,Ext.Component,{
    combo:{},config: {}
});

Ext.reg('wkcmp',wkCmp);
/**
 * onsave combo data: 
 */ 

if ( VersionX.config.publish_document ) {
    var onsaveData = [
        [1, _('versionx.workflow.combo.draft'), 'draft' ],// note that id for the record is the first element
        [2, _('versionx.workflow.combo.published'), 'publish'],
        [3, _('versionx.workflow.combo.unpublish'), 'unpublish' ],
        [4, _('versionx.workflow.combo.approvedraft'), 'approve'],
        [5, _('versionx.workflow.combo.rejectdraft'), 'reject']
    ];
} else {
    var onsaveData = [
        [1, _('versionx.workflow.combo.draft'), 'draft' ],
        [2, _('versionx.workflow.combo.submitapproval'), 'submitted']
    ];
}
var onsaveStore = new Ext.data.ArrayStore({
    fields: ['id', 'name', 'code'],
    data: onsaveData,
    idIndex: 0 // id for each record will be the first element
});
// create a Record constructor:
var rt = Ext.data.Record.create([
    'id',
    'name',
    'code'
]);
var onsaveStore = new Ext.data.Store({
    // explicitly create reader
    reader: new Ext.data.ArrayReader({
            idIndex: 0  // id for each record will be the first element
        },
        rt // recordType
    )
});
onsaveStore.loadData(onsaveData);

/**
 * revision type combo data:
 */

var revisiontypeData = [
    [1, _('versionx.workflow.combo.minorrevision'), 'minor' ],
    [2, _('versionx.workflow.combo.majorrevision'), 'major']
];
var revisiontypeStore = new Ext.data.ArrayStore({
    fields: ['id', 'name','code'],
    data: revisiontypeData,
    idIndex: 0 // id for each record will be the first element
});
// create a Record constructor:
var revisiontypeRt = Ext.data.Record.create([
    'id',
    'name',
    'code'
]);
var revisiontypeStore = new Ext.data.Store({
    // explicitly create reader
    reader: new Ext.data.ArrayReader({
            idIndex: 0  // id for each record will be the first element
        },
        revisiontypeRt // recordType
    )
});
revisiontypeStore.loadData(revisiontypeData);

var wkLoaded = false;

wkCmp = new wkCmp();

    MODx.on("ready",function() {
        // create the drop downs:
        wkCmp.combo.OnSave = function(config) {
            config = config || {};
            Ext.applyIf(config,{
                store: onsaveStore//['Save as Draft', 'Submit for Approval','Published','Approve Draft','Reject Draft']
                ,mode: 'local'
                ,editable: false
                ,fields: ['id', 'name', 'code']
                ,displayField: 'code'
                ,valueField: 'code'
                ,value: 'draft'
                ,minChars : 0  
            });
            wkCmp.combo.OnSave.superclass.constructor.call(this,config);
        };
        //Ext.extend(MODx.combo.SlideStatus, MODx.combo.ComboBox);
        Ext.extend(wkCmp.combo.OnSave,MODx.combo.ComboBox);
        Ext.reg('workflow-onsave-combo', wkCmp.combo.OnSave);
        
        wkCmp.combo.RevisionType = function(config) {
            config = config || {};
            Ext.applyIf(config,{
                store: revisiontypeStore
                ,mode: 'local'
                ,editable: false
                ,fields: ['id', 'name', 'code']
                ,valueField: 'code'  
                ,displayField: 'code'
                ,value: 'minor'
                ,minChars : 0
            });
            wkCmp.combo.RevisionType.superclass.constructor.call(this,config);
        };
        //Ext.extend(MODx.combo.SlideStatus, MODx.combo.ComboBox);
        Ext.extend(wkCmp.combo.RevisionType,MODx.combo.ComboBox);
        Ext.reg('workflow-revisiontype-combo', wkCmp.combo.RevisionType);
        
        // Add Workflow options to the document page:
        var wkObject = {
            layout:'column'
            ,border: false
            ,anchor: '100%'
            ,id: 'modx-resource-main-columns2'
            ,defaults: {
                labelSeparator: ''
                ,labelAlign: 'top'
                ,border: false
                ,msgTarget: 'under'
                /* does not work ,listeners: {
                    'afteredit': {fn:this.fieldChangeEvent,scope:this}
                }*/
            }
            ,items:[{
                    columnWidth: .33
                    ,layout: 'form'
                    ,border: false
                    ,id: 'modx-resource-main-left2'
                    ,defaults: { 
                    	msgTarget: 'under'
	                    ,listeners: {
				            'expand': { fn:function(p) {
					            	Ext.getCmp('modx-panel-resource').markDirty();
					        	 }
					         	,scope:this
					        }
						} 
					}
                    ,items: [{
                        xtype: 'workflow-onsave-combo'
                        ,fieldLabel: _('versionx.workflow.onsave')
                        ,description: _('versionx.workflow.onsave.help')
                        ,name: 'version_publish'
                        ,fields: ['id', 'name', 'code']
                        ,valueField: 'code'
                        //,value: 'draft'
                        //,inputValue: 'Draft'
                        ,left:0
                        ,renderer: 'value'
                        ,anchor: '100%'
                    }]
                },{
                    columnWidth: .33
                    ,layout: 'form'
                    ,labelWidth: 0
                    ,border: false
                    ,id: 'modx-resource-main-center'
                    ,style: ''
                    ,defaults: { 
                    	msgTarget: 'under'
                    	,listeners: {
				            'render': function(c) {
						      c.getEl().on('keyup', function() {
						        Ext.getCmp('modx-panel-resource').markDirty();
						      }, c);
						    }
						}
                    }
                    ,items: [{
                        xtype: 'workflow-revisiontype-combo'
                        ,fieldLabel: _('versionx.workflow.revisiontype')
                        ,description: _('versionx.workflow.revisiontype.help')
                        ,name: 'version_revisiontype'
                        //,value:'minor'
                        ,left:0
                        ,renderer: 'value'
                        ,anchor: '100%'
                    }]
                },{
                    columnWidth: .33
                    ,layout: 'form'
                    ,labelWidth: 0
                    ,border: false
                    ,id: 'modx-resource-main-right2'
                    ,style: 'margin-right: 0'
                    ,defaults: { 
                    	msgTarget: 'under'
                    	,listeners: {
	                    	'render': function(c) {
						      c.getEl().on('keyup', function() {
						        Ext.getCmp('modx-panel-resource').markDirty();
						      }, c);
						    }
						}
                    }
                    ,items: [{
                            xtype: 'textfield'
                            ,fieldLabel: _('versionx.workflow.sendto') + ' Send to '
                            ,description: _('versionx.workflow.sendto.help')
                            ,name: 'version_sendto'
                            ,anchor: '100%'
                        }]
                },{
                    columnWidth: .67
                    ,layout: 'form'
                    ,id: 'modx-resource-main-notes'
                    ,defaults: { 
                    	msgTarget: 'under'
                    	,listeners: {
				            'render': function(c) {
						      c.getEl().on('keyup', function() {
						        Ext.getCmp('modx-panel-resource').markDirty();
						      }, c);
						    }
						}
                    }
                    ,items: [{
                            xtype: 'textarea'
                            ,fieldLabel: _('versionx.workflow.notes')
                            ,description: _('versionx.workflow.notes.help')
                            ,name: 'version_notes'
                            ,grow: true
                            ,anchor: '100%'
                        }]
                },{
                    columnWidth: .33
                    ,layout: 'form'
                    ,labelWidth: 0
                    ,border: false
                    ,id: 'modx-resource-main-right3'
                    ,style: 'margin-right: 0'
                    ,defaults: { 
                    	msgTarget: 'under'
                    }
                    ,items: [{
                            xtype: 'tbbutton'
                            ,text: _('versionx.workflow.previewbutton')
                            ,handler: function(f){
                                if (VersionX.draftUrl == '' ) {
                                    f.disable();
                                } else {
                                    window.open(VersionX.draftUrl);
                                }
                            }
                        }]
                }]
        };
        
        
        var resourcePanel = Ext.getCmp('modx-resource-settings');// 'modx-panel-resource');// 
        if ( resourcePanel && !wkLoaded ) {
            resourcePanel.add(wkObject);
            wkLoaded = true;
            /*({
                html: '<h2>This is an added feild</h2>'
                ,width: '100%'
                ,id: 'tv-tr-out-2'
                ,cls: 'modx-tv-out2'
            });*/
            //resourcePanel.doLayout();
        }
        // hide the Publish checkbox: modx-resource-published
        MODx.hideField("modx-panel-resource",["published"]);
        /*
        if (!Ext.isArray(tvs)) { tvs = [tvs]; }
        var tvp = Ext.getCmp('modx-panel-resource-tv');
        */
        
        
    });
</script>