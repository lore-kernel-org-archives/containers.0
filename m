From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: fix freezing groups with stopped tasks
Date: Thu, 24 Nov 2011 22:52:02 +0100
Message-ID: <20111124215202.GB6312__9050.26861369169$1322171545$gmane$org@tiehlicka.suse.cz>
References: <1321480234-29241-1-git-send-email-mhocko@suse.cz>
	<20111121230709.GR25776@google.com>
	<4ECB06D2.6060106@cn.fujitsu.com>
	<20111122022118.GT25776@google.com>
	<20111122090522.GA26768@tiehlicka.suse.cz>
	<20111122153948.GE322@google.com> <20111122154748.GF322@google.com>
	<20111124100454.GE26036@tiehlicka.suse.cz>
	<20111124200009.GB6735@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111124200009.GB6735-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu 24-11-11 12:00:09, Tejun Heo wrote:
> On Thu, Nov 24, 2011 at 11:04:54AM +0100, Michal Hocko wrote:
> > On Tue 22-11-11 07:48:06, Tejun Heo wrote:
> > > On Tue, Nov 22, 2011 at 07:39:48AM -0800, Tejun Heo wrote:
> > > > > Signed-off-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> > > > > Cc: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
> > > > > Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> > > > > Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > > > > Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> > > > > Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > > 
> > > > Applying to cgroup/for-3.2-fixes.
> > > 
> > > I'll apply the original version in cgroup/for-3.2-fixes and deal with
> > > conflict once pm-freezer branch is merged.  
> > 
> > Are you going to push this to the stable trees as well, or should I do
> > it?
> 
> Tagged w/ stable.  Will push it upstream next week and the next stable
> release will pick it up.

Great, thanks!

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
