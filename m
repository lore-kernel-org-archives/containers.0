From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2] /proc/pid/status: show all sets of pid according to ns
Date: Wed, 28 May 2014 22:28:24 +0400
Message-ID: <20140528182824.GA5057@cachalot>
References: <1401272683-1659-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5385DA19.2060008@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5385DA19.2060008-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, May 28, 2014 at 16:44 +0400, Pavel Emelyanov wrote:
> On 05/28/2014 02:24 PM, Chen Hanxiao wrote:
> > We need a direct method of getting the pid inside containers.
> 
> But there's more generic issue -- some day we'll need to know not only
> PIDs as seen from different namespaces, but also SIDs and PGIDs.

Maybe include all per-ns ID in a separate file?  Then the old 'status'
file includes IDs from the current namespace only, the new file (e.g.
'ids' or 'ns_ids') contains only hierarchical IDs which differ from
namespace to namespace for all possible namespaces.  It will be simplier
to parse the file -- if 'ns_ids' file contains some ID then this ID for
every ns can be obtained regardless of the specific ID name (SID, PID,
PGID, etc.).

> 
> > If some issues occurred inside container guest, host user
> > could not know which process is in trouble just by guest pid:
> > the users of container guest only knew the pid inside containers.
> > This will bring obstacle for trouble shooting.
> > 
> > This patch adds two fields:
> > 
> > NStgid and NSpid.
> > 
> > a) In init_pid_ns, nothing changed;
> > 
> > b) In one pidns, will tell the pid inside containers:
> > NStgid:	1628 	9 	3
> > NSpid:	1628 	9 	3
> > ** Process id is 1628 in level 0, 9 in level 1, 3 in level 2.
> > 
> > c) If pidns is nested, it depends on which pidns are you in.
> > NStgid:	9 	3
> > NSpid:	9 	3
> > ** Views from level 1

Thanks,

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments
