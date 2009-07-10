From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] CGroups: cgroup member list enhancement/fix
Date: Fri, 10 Jul 2009 16:58:23 -0700
Message-ID: <6599ad830907101658i13e4046br70377a487dd6b49b__47980.3804694258$1247270341$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090705063850.GX11273@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090705063850.GX11273-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Jul 4, 2009 at 11:38 PM, Balbir Singh<balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
> Paul, I don't see an interface to migrate all procs or at-least I
> can't read it in the changelog. As discussed in the containers
> mini-summit in 2008, it would be a nice thing to have (I've not looked
> at the implementation yet).
>

We're still working on that bit.

We want to provide the guarantee that if you write a tgid to the procs
file, all its threads get migrated even if you race with a clone()
call, and are trying to figure out a nice way to do that without
introducing unnecessary overhead/synchronization in the fork path.

Paul
