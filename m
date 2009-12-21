From: Ian Molton <ian.molton-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Subject: Re: Fw: cgroups and dbus
Date: Mon, 21 Dec 2009 10:03:58 +0000
Message-ID: <4B2F480E.8090303__41802.8929656886$1261389979$gmane$org@collabora.co.uk>
References: <20091221142438.1c70fadb.kamezawa.hiroyu@jp.fujitsu.com>
	<661de9470912202135s5869f0d0w6379ef6f3a668e8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <661de9470912202135s5869f0d0w6379ef6f3a668e8a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> On Mon, Dec 21, 2009 at 10:54 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> 
>> Forwarding to container mailing list. Sorry, I myself don't have quick
>> answer. But, hmm, what you want cannot be achieved with libcgroup ?

Cheers guys,

my subscription to containers@ hasnt come through yet so please CC me :)

I'm working on implementing a kernel-based dbus solution, where the
'daemon' is more of a routing manager that updates some in kernel
tables, allowing a lightweight kernel daemon to route messages
appropriately, and thus reducing the number of context switches needed
to send messages by half.

DBus has the concepts of 'system' and 'session' busses, and it seems
like cgroups could be a good fit for determining which busses an
application is on.

AIUI, an application can be connected to:

1) The system bus
2) A session bus (singular)
3) Both of the above
4) A private (point to point) bus

so ideally we would need a process to inherit the system bus cgroup from
its parent, and also be able to be in a session bus cgroup (which would
be mutually exclusive with being in another session bus cgroup).

Point to point dbus connections could happily continue using unix
sockets (or whatever). These have neever been under the control of
dbus-daemon anyway.
