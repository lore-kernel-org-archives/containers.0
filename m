From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: Fw: cgroups and dbus
Date: Tue, 22 Dec 2009 13:46:49 +0900
Message-ID: <20091222134649.61a0e290.kamezawa.hiroyu__25474.7612205849$1261457475$gmane$org@jp.fujitsu.com>
References: <20091221142438.1c70fadb.kamezawa.hiroyu@jp.fujitsu.com>
	<661de9470912202135s5869f0d0w6379ef6f3a668e8a@mail.gmail.com>
	<4B2F480E.8090303@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B2F480E.8090303-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian Molton <ian.molton-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 21 Dec 2009 10:03:58 +0000
Ian Molton <ian.molton-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org> wrote:

> Balbir Singh wrote:
> > On Mon, Dec 21, 2009 at 10:54 AM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > 
> >> Forwarding to container mailing list. Sorry, I myself don't have quick
> >> answer. But, hmm, what you want cannot be achieved with libcgroup ?
> 
> Cheers guys,
> 
> my subscription to containers@ hasnt come through yet so please CC me :)
> 
> I'm working on implementing a kernel-based dbus solution, where the
> 'daemon' is more of a routing manager that updates some in kernel
> tables, allowing a lightweight kernel daemon to route messages
> appropriately, and thus reducing the number of context switches needed
> to send messages by half.
> 
> DBus has the concepts of 'system' and 'session' busses, and it seems
> like cgroups could be a good fit for determining which busses an
> application is on.
> 
> AIUI, an application can be connected to:
> 
I'm not sure wheter this kind of moving function from user to kernel
is welcomed or not..


> 1) The system bus
> 2) A session bus (singular)
> 3) Both of the above
> 4) A private (point to point) bus
> 
> so ideally we would need a process to inherit the system bus cgroup from
> its parent, and also be able to be in a session bus cgroup (which would
> be mutually exclusive with being in another session bus cgroup).
> 
> Point to point dbus connections could happily continue using unix
> sockets (or whatever). These have neever been under the control of
> dbus-daemon anyway.
> 

It seems what you asked was an example of cgroup.
Maybe the simplest cgroup in the kernel is CONFIG_CGROUP_CPUACCT. 
(kernel/sched.c) The next one is CGROUP_DEVICE (security/device_cgroup.c)

Documentation under Documentation/cgroups/ is always taken care to be updated.
If you notice some description is unclear or obsolete, please report it.

Thanks,
-Kame
