From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix reverse unlock sequence in cgroup_get_sb
Date: Tue, 21 Jul 2009 08:34:51 -0700
Message-ID: <6599ad830907210834y30e7d57aj978898a300a447d0__32934.7246014096$1248190574$gmane$org@mail.gmail.com>
References: <1248171926-20232-1-git-send-email-dfeng@redhat.com>
	<20090721111019.GV24157@balbir.in.ibm.com>
	<8522a3d30907210438u6fce081fi835bf964d0c01e8a@mail.gmail.com>
	<20090721120106.GW24157@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090721120106.GW24157-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Zefan Li <lizf.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 21, 2009 at 5:01 AM, Balbir Singh<balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
> lock(A)
> lock(B)
> unlock(A)
> unlock(B)
>
> Tomorrow if a unsuspecting programmer does this
>
> lock(A)
> lock(B)
> unlock(A)
>
> code block
>
> unlock(B)
>
>
> What protects code block? lock B? Is that the intention?
>

An "unsuspecting programmer" shouldn't be adding code to
multi-threaded routines without thoroughly understanding the locking.

I guess there's no harm in this patch, but as Li says, it doesn't
really change anything.

Paul
