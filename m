From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 2/3] cgroup: mark "notify_on_release"
	and "release_agent" cgroup files insane
Date: Wed, 5 Jun 2013 10:47:11 +0400
Message-ID: <51AEDEEF.8090608__49336.4511560232$1370414796$gmane$org@parallels.com>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604021355.GI29989@mtj.dyndns.org>
	<51ADC5D3.5070108@huawei.com>
	<20130604200003.GC14916@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130604200003.GC14916-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/05/2013 12:00 AM, Tejun Heo wrote:
> On Tue, Jun 04, 2013 at 06:47:47PM +0800, Li Zefan wrote:
>> On 2013/6/4 10:13, Tejun Heo wrote:
>>> The empty cgroup notification mechanism currently implemented in
>>> cgroup is tragically outdated.  Forking and execing userland process
>>> stopped being a viable notification mechanism more than a decade ago.
>>> We're gonna have a saner mechanism.  Let's make it clear that this
>>> abomination is going away.
>>>
>>> Mark "notify_on_release" and "release_agent" with CFTYPE_INSANE.
>>>
>>
>> Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>
>> Do you plan to implement the alternative mechanism for 3.11?
> 
> No idea about the timeframe at this moment.  Hoping to do it in this
> year.
> 

A notification mechanism would be very welcome for us. The problem we
have now, is that if a container halts itself, we have no way to do any
cleanup. Doing it would involve having a daemon to scan for
no-longer-alive groups and shut them down.

The current mechanism proved unusable for us as well, because they are
global and used by systemd. We would like to register our own handler
(it would be fine if systemd would allow us to do so, being still the
only one hooked to the global handler)
