From: Vasily Averin <vvs-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: question about default values for per-namespace settings
Date: Thu, 15 May 2014 13:01:52 +0400
Message-ID: <53748280.60906@parallels.com>
References: <20140512140706.GA22082@macbook.localnet>
	<cover.1399909529.git.vvs@openvz.org>
	<5370F781.7010909@parallels.com> <53711B21.1060309@pandora.be>
	<53712B0A.7060007@parallels.com> <53727246.4050306@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53727246.4050306-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Dear Tejun,

how do you think, which defaults should be used for per-namespace settings in general case
and for per-netns sysctls especially? Do we have some common position about this or
perhaps we already have some setting that allows to select desired behavior?

I'm preparing patch that makes per-netns sysctls in br_netfilter,
to be able to enable/disable br-nf-call processing in each network namespace independently.

I've initialized sysctl values in each netns by system defaults, like it was done in similar cases.
However Bart pointed that "this does introduce a bit of backwards incompatibility":
currently all netns shares the br_netfilter sysctl settings applied in init_net.

From OpenVz point of view containers should be properly isolated,
should have predictable initial configuration
and should not depend on settings applied in another containers.
On the other hand independent containers is only one of possible usecases,
and I have no strong objections against Bart's proposal. Frankly speaking
initially I've planned to copy setting from init_net too.

To make possible both variants I can introduce one more setting,
it allows to specify desired behavior:
to use system defaults or to copy current settings from init_net.

However probably the same dilemma was observed in another subsystems?
Perhaps this selector already exists?

If isn't, how do you think, should I introduce some new global parameter,
or may be it should be some local bridge-only-related setting?

Thank you,
	Vasily Averin

you can find some more details about my patch in netfilter-devel@
[PATCH RFC v3 2/2] br_netfilter: per-netns copy of structure for sysctl flags
On 05/13/2014 11:28 PM, Bart De Schuymer wrote:
> Vasily Averin schreef op 12/05/2014 22:11:
>> On 05/12/2014 11:04 PM, Bart De Schuymer wrote:
>>> Vasily Averin schreef op 12/05/2014 18:32:
>>>> pernet_operations creates per-netns copy of common structure for sysctl flags
>>>> and initialize it values taken from init_brnf_net.
>>>>
>>>> Signed-off-by: Vasily Averin <vvs-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>>>
>>>> +static int __net_init brnf_net_init(struct net *net)
>>>> +{
>>>> +    struct brnf_net *bn = brnf_net(net);
>>>> +
>>>> +    memcpy(bn, &init_brnf_net, sizeof(struct brnf_net));
>>>> +    bn->net = net;
>>>> +    return brnf_sysctl_net_register(bn);
>>>
>>> This does introduce a bit of backwards incompatibility (easily fixed
>>> by adapting scripts), but this is really unavoidable when
>>> transforming an existing global configuration to a per-netns
>>> configuration. I'm ok with it.
>>
>> Could you please explain, which backward incompatibility you mean here?
>> Nobody changes values init_brnf_net,
>> init_net have own copy, like any other network namespaces.
> 
> Well, init_brnf_net is never written to, so it keeps the default flags.
> If a new netns is created, a copy of the contents of init_brnf_net is made. So, whenever a netns is created, it starts with the default flags (e.g. brnf_call_iptables is always 1 for a newly created netns).
> 
> In the current kernel, when a new netns is created, the configuration of the main netns is used (the proc system doesn't even show the flags in the created netns): if brnf_call_iptables is 0 before the new netns is created, iptables won't see bridged IP traffic in the new netns.
> With your patch, this behaviour will change.
> 
> It's possible to alter your patch to keep the same behaviour as before at netns creation, but always starting from the same defaults is cleaner.
