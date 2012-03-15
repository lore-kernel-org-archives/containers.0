From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] cgroup: deprecate remount option changes and "name="
	mount option
Date: Thu, 15 Mar 2012 09:54:02 -0700
Message-ID: <20120315165402.GC32137__41081.9266261116$1331830456$gmane$org@google.com>
References: <20120314215228.GI7349@google.com>
	<20120314232925.GA16973@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120314232925.GA16973-kS5D54t9nk0aINubkmmoJbNAH6kLmebB@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Thu, Mar 15, 2012 at 12:29:25AM +0100, Lennart Poettering wrote:
> Hmm, this is not clear to me. Are you intending to remove the name=
> mount option entirely, or just intend to remove that you can change it
> in remounts?
> 
> systemd uses name=systemd to get its own private cgroup tree, that has
> no controller bound, hence we kinda need this option. Or are you
> suggesting there was an other way to get a private cgroup tree that
> systemd can use for grouping and labelling things?

Eh, you're right.  I want to remove support for duplicate mounting by
name or subsys as it just isn't necessary, so what I want is,

* "mount -t cgroupfs -o SUBSYS" will fail if SUBSYS is already mounted
  somewhere else.

* "mount -t cgroupfs -o none" will always create a new cgroup
  hierarchy w/o any controller attached.

I didn't realize that the mount code didn't allow none w/o name and
now I don't see a non-intrusive way to remove the name option. :( Eh
well, I'll drop that part.

Thanks.

-- 
tejun
