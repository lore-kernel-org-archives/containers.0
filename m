From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cgroup_freezer: allow migration
	regardless of freezer state and update locking
Date: Sun, 21 Oct 2012 21:18:53 +0200
Message-ID: <20121021191853.GB26218@redhat.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<2424755.Pg0O5tTD3k@vostro.rjw.lan>
	<20121019200421.GO13370@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121019200421.GO13370-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/19, Tejun Heo wrote:
>
> On Fri, Oct 19, 2012 at 06:54:42PM +0200, Rafael J. Wysocki wrote:
> > >  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup_freezer-locking
> >
> > It seems that no one has any comments. :-)
> >
> > Are you going to prepare a branch for me to pull from?
>
> I'm waiting for Oleg to poke some holes in the synchronization
> department but if that doesn't happen you can pull from the above
> branch.  I'll pull it into cgroup/for-3.8 too.

Just in case, I see nothing bad ;)

But let me repeat I never understood this code in details, and I
already forget everything.

Oleg.
