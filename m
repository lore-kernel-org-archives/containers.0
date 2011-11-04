From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] add new cgroup list to CC notice
Date: Fri, 04 Nov 2011 14:17:45 +0100
Message-ID: <4EB3E5F9.80308__40659.0531616986$1320413299$gmane$org@free.fr>
References: <20111104094030.cf8d5860.kamezawa.hiroyu@jp.fujitsu.com>
	<4EB3495B.8080700@free.fr> <1320382250.3108.4.camel@dabdike>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320382250.3108.4.camel@dabdike>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, "hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org" <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/04/2011 05:50 AM, James Bottomley wrote:
> On Fri, 2011-11-04 at 03:09 +0100, Daniel Lezcano wrote:
>> On 11/04/2011 01:40 AM, KAMEZAWA Hiroyuki wrote:
>>> As discussed at Kernel Summit(2011), new cgroups mailing list is opened by
>>> James. This list is for discussing general cgroup design and patches
>>> including all subsystems and for getting more attentions to cgroups/namespaces
>>> related issues by developpers.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>>> ---
>> I don't see the point to unilaterally change the mailing list to
>> vger.kernel.org as the discussions will be  the same as the actual
>> mailing list containers@.
> It's not a unilateral list change.  We will still have containers@lf.
>
> The problem is that not all cgroup related stuff goes over it ...
> particularly the currently active controller discussions tend not to be
> cc'd there.  With systemd (and things like the I/O controllers for
> xen/kvm), cgroups is seen as being wider than containers.
>
> The desire was for a single list where someone could go to get an
> overall view of what's going on in cgroups ... particularly if you're a
> confused subsystem maintainer who just had a request to put a controller
> in your subsystem ...

Ok, thanks for the clarification. May I suggest to create also a 
namespace@ mailing list ?
