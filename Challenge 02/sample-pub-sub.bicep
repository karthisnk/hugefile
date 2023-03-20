resource egt_22th_subscriber 'Microsoft.EventGrid/eventSubscriptions@2020-06-01' = {
  scope: egt_topic
  name: 'season-field-update-subscriber'
  properties: {
    destination: {
      endpointType: 'ServiceBusQueue'
      properties: {
        resourceId: sb_namespace_22th_queue.id
      }
    }
    eventDeliverySchema: 'CustomInputSchema'
    deadLetterDestination:{
      endpointType:'StorageBlob'
      properties:{
        blobContainerName:'season-field-update-dead-letter'
        resourceId:dead_letter_storage_egt.id
      }
    }
    filter: {
      advancedFilters: [
        {
          operatorType: 'StringNotIn'
          key: 'action'
          values: [
            'Deleted'
          ]
        }
      ]
      includedEventTypes: [
        'SeasonField'
        'AsPlanted'
        'AsHarvested'
      ]
      isSubjectCaseSensitive: false  
    }
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 120
    }
  }
  dependsOn: [
    dead_letter_storage_egt_container22
  ]
}

resource keyvault_sb_boundary_change_v2_queue_read_key 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'kv-digitalag-${env}-eus2/servicebus-connectionstring-boundary-change-listen'
  properties: {
    value: 'Endpoint=sb://${sb_namespace.name}.servicebus.windows.net/;SharedAccessKeyName=${sb_namespace_boundary_change_v2_queue_read_key.name};SharedAccessKey=${sb_namespace_boundary_change_v2_queue_read_key.listkeys().primarykey};'
  }
  dependsOn:[
    sb_document_storage_queue_read_key
  ]
}

resource keyvault_egt_endpoint_pub_sub 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'kv-digitalag-${env}-eus2/eventgridtopic-endpoint-pubsub-migration'
  properties: {
    value: egt_topic.properties.endpoint
  }
}

resource keyvault_egt_key_pub_sub 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'kv-digitalag-${env}-eus2/eventgridtopic-key-pubsub-migration'
  properties: {
    value: listkeys(egt_topic.id,egt_topic.apiVersion).key1
  }
}
