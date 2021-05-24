## Traffic Management

### EnvoyFilter
```
EnvoyFilter
EnvoyFilter.ProxyMatch
EnvoyFilter.ClusterMatch
EnvoyFilter.ListenerMatch
EnvoyFilter.EnvoyConfigObjectMatch
EnvoyFilter.EnvoyConfigObjectPatch

EnvoyFilter.RouteConfigurationMatch
EnvoyFilter.RouteConfigurationMatch.RouteMatch
EnvoyFilter.RouteConfigurationMatch.RouteMatch.Action
EnvoyFilter.RouteConfigurationMatch.VirtualHostMatch

EnvoyFilter.ListenerMatch.FilterChainMatch
EnvoyFilter.ListenerMatch.FilterMatch
EnvoyFilter.ListenerMatch.SubFilterMatch

EnvoyFilter.Patch
EnvoyFilter.Patch.Operation
EnvoyFilter.Patch.FilterClass
EnvoyFilter.PatchContext

EnvoyFilter.ApplyTo
```

配置层级:
```yaml
EnvoyFilter:
    workloadSelector
        labels:	map<string, string>
    configPatches
        EnvoyConfigObjectPatch[]:
            applyTo:
                - INVALID: 
                - LISTENER    : Applies the patch to the listener.
                - FILTER_CHAIN    : Applies the patch to the filter chain.
                - NETWORK_FILTER  : Applies the patch to the network filter chain, to modify an existing filter or add a new filter.
                - HTTP_FILTER : Applies the patch to the HTTP filter chain in the http connection manager, to modify an existing filter or add a new filter.
                - ROUTE_CONFIGURATION : Applies the patch to the Route configuration (rds output) inside a HTTP connection manager. This does not apply to the virtual host. Currently, only MERGE operation is allowed on the route configuration objects.
                - VIRTUAL_HOST    : Applies the patch to a virtual host inside a route configuration.
                - HTTP_ROUTE  : Applies the patch to a route object inside the matched virtual host in a route configuration.
                - CLUSTER : Applies the patch to a cluster in a CDS output. Also used to add new clusters.
                - EXTENSION_CONFIG    : Applies the patch to or adds an extension config in ECDS output. Note that ECDS is only supported by HTTP filters.
            match: EnvoyConfigObjectMatch
                context: PatchContext
                    - ANY
                    - SIDECAR_INBOUND
                    - SIDECAR_OUTBOUND
                    - GATEWAY
                proxy: ProxyMatch
                    - proxyVersion: string
                    - metadata: map<string,string>
                listener: ListenerMatch(oneof)
                    - portNumber: unit32
                    - filterChain: FilterChainMatch
                        - name: string
                        - sni: string
                        - transportProtocal: string
                        - applicationProtocols: string
                        - filter: FilterMatch
                            - name: string
                            - subFilter: SubFilterMatch
                                - name: string
                        - destinationPort: unit32
                    - name: string
                routeConfiguration: RouteConfigurationMatch(oneof)
                    -  portNumber: unit32
                    - portName: string
                    - gateway: string
                    - vhost: VirtualHostMatch
                        - name: string
                        - route: RouteMatch
                            - name: string
                            - action: Action
                                - ANY
                                - ROUTE
                                - REDIRECT
                                - DIRECT_RESPONSE
                    - name: string
                cluster: ClusterMatch(oneof)
                    - portNumber: unit32
                    - service: string
                    - subset: string
                    - name: string
            patch: Patch
                operation: Operation
                    - INVALID
                    - MERGE
                    - ADD
                    - REMOVE
                    - INSERT_BEFORE
                    - INSERT_AFTER
                    - INSERT_FIRST
                    - REPLACE
                value: Struct
                    - fields: map<sting, Value>
                        - null_value
                        - number_value
                        - string_value
                        - bool_value
                        - struct_value
                        - list_value
                filterClass: FilterClass
                    - UNSPECIFIED
                    - AUTHN: 认证
                    - AUTHZ: 授权
                    - STATS
```