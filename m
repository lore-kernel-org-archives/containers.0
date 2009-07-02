From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/9] [RFC] Support multiply-bindable cgroup subsystems
Date: Wed, 1 Jul 2009 22:04:19 -0700
Message-ID: <6599ad830907012204i20fed7a9ud4ae5610cfc9a6ae@mail.gmail.com>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021128.14469.3360.stgit@menage.mtv.corp.google.com>
	<20090702114555.b7253edf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907011952t2e698e77j1e8dba21402bc9a9@mail.gmail.com>
	<20090702121626.7676c7d4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702121626.7676c7d4.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
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

On Wed, Jul 1, 2009 at 8:16 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>
> Hm, then, moving SUBSYS() macro to linux/cgroup_subsys.h is a sane way, I=
 think.
> IMHO, it's not very good habit that cgroup_subsys.h is parsed in differen=
t ways in
> cgroup.h and cgroup.c
>
> I think cgroup_subsys.h like following is much simpler even if it's not v=
ery
> sophisticated.


> =3D=3D
> #define SUBSYSID(_name) =A0 =A0 =A0 =A0 _name ## _subsys_id,
> #define SUBSYSP(_name) =A0 =A0 =A0 =A0 =A0&_name ## _subsys,

You'd also need a macro for the extern declaration of each *_subsys
variable. So it would be 8 lines of boilerplate for each subsystem,
plus adding to the CGROUP_ALL_* macros below. Yes, it could be done
that way, but I'm not convinced that it's hugely simpler.

The state of things prior to this patch series is that to do something
at compile time that involves all subsystems (currently we have three
cases - defining the subsys_id enum, declaring the extern subsys
structures, and defining the array of subsys structure pointers) you
just define the macro SUBSYS to expand to the code fragment you want
to repeat and include cgroup_subsys.h. This is very simple from the
subsystem writer's PoV, and not too tricky in the core framework.

I agree that this patch does increase the complexity in the framework
code, since the framework code needs to deal with all the non-multi
subsystems ahead of all multi-subsystems, and so has to do two passes
through the file.

OK, thinking more about this, your earlier suggestion of splitting
cgroup_subsys.h and using a single SUBSYS macro would achieve this
more simply after all. Let me try that and see how it looks.

Paul
