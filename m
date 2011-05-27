From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] iproute2: Add processless network namespace support.
Date: Thu, 26 May 2011 17:45:10 -0700
Message-ID: <m1ei3lc6p5.fsf@fess.ebiederm.org>
References: <m1hb8hyyaj.fsf@fess.ebiederm.org> <4DDEC793.8040502@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4DDEC793.8040502@genband.com> (Chris Friesen's message of "Thu,
	26 May 2011 15:35:15 -0600")
Sender: netdev-owner@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Chris Friesen <chris.friesen@genband.com> writes:

> On 05/26/2011 02:58 PM, Eric W. Biederman wrote:
>>
>> The goal of this code change is to implement a mechanism such that it is
>> simple to work with a kernel that is using multiple network namespaces
>> at once.
>>
>> This comes in handy for interacting with vpns where there may be rfc1918
>> address overlaps, and different policies default routes, name servers
>> and the like.
>>
>> Configuration specific to a network namespace that would ordinarily be
>> stored under /etc/ is stored under /etc/netns/<name>.  For example if
>> the dns server configuration is different for your vpn you would create
>> a file /etc/netns/myvpn/resolv.conf.
>
> That would be interesting.  Currently I use dnsmasq to keep my DNS servers
> straight when connecting in to two different corporate VPNs simultaneously.
>
> I could see it being interesting trying to remember which shell sessions were
> running in which network namespace...

Keeping shells straight is keeping shells straight, and I haven't had
an particular trouble with that.  I can always look at ifconfig or
/etc/resolv.conf if I am wondering which namespace a shell is in.

Now that I think about it there is some ongoing work to test two
network namespaces for identity and as that matures it probably
makes sense to extend this code to add a "ip netns id" command.

For me there has been real benefit in not having to deal with
conflicting default routes, conflicting ip addresses, or conflicting
hostnames (assuming you put all of the right domain names in your search
path), and I don't have to worry about accidentally bridging traffic.

In general I think it is simpler model to get right than natting remote
networks into my own network, using multiple ip tables so I can cope
with multiple default routes, and setting dnsmasq, and a long search
path in resolv.conf so I can resolve host names that are not fully
qualified that might come over the vpn.  Not that there aren't
benefits to doing all of that.

In practice after I had ip patched all it took was a longish openvpn
up-script (an afternoons hack) (so I could move the tap device to the
new network namespace and intercept all of the ifconfig or ip commands
that openvpn would normally run and run them instead in the network
namespace).

Eric
