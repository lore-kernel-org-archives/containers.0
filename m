From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/9] [RFC] Support multiply-bindable cgroup subsystems
Date: Wed, 1 Jul 2009 19:52:16 -0700
Message-ID: <6599ad830907011952t2e698e77j1e8dba21402bc9a9@mail.gmail.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021128.14469.3360.stgit@menage.mtv.corp.google.com>
	<20090702114555.b7253edf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702114555.b7253edf.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 1, 2009 at 7:45 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>> - in the current version of this patch, mounting a cgroups hierarchy
>> =A0 with no options does *not* get you any of the multi-bindable
>> =A0 subsystems; possibly for consistency it should give you all of the
>> =A0 multi-bindable subsystems as well as all of the single-bindable
>> =A0 subsystems.
>>
> I don't think this is a big problem. Hmm, I wonder there are no people who
> uses cgroup without any options (=3D mounts all subsys at once)...

In practice I suspect that it's a rare usage outside of manual
playing/testing - any real production system is going to want to be
aware of what subsystems are available and decide which to mount on
each hierarchy.

>
> Wow...seems complicated. How about adding linux/cgroup_multisubsys.h ?

I think that the readability benefits in cgroup.c would be outweighed
by having two different subsys include files.

Paul
