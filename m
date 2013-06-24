From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/6] cgroup: clean up find_css_set() and friends
Date: Mon, 24 Jun 2013 13:03:30 -0700
Message-ID: <20130624200330.GH1918__22171.5648578995$1372104229$gmane$org@mtj.dyndns.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-5-git-send-email-tj@kernel.org>
	<51C8206F.90404@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51C8206F.90404-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 24, 2013 at 06:33:19PM +0800, Li Zefan wrote:
> On 2013/6/22 9:34, Tejun Heo wrote:
> > find_css_set() passes uninitialized on-stack template[] array to
> > find_existing_css_set() which sets the entries for all subsystems.
> > Passing around an uninitialized array is a bit icky and we want to
> > introduce an iterator which only iterates loaded subsystems.  Let's
> > initialize it on definition.
> > 
> > While at it, also make the following cosmetic cleanups.
> > 
> > * Convert to proper /** comments.
> > 
> 
> I thought we only use this for external functions, but then I read
> Documentation/kernel-doc-nano-HOWTO.txt:
> 
> We also recommend providing kernel-doc formatted documentation
> for private (file "static") routines, for consistency of kernel
> source code layout.  But this is lower priority and at the
> discretion of the MAINTAINER of that kernel source file.

Yeah, for functions which are tricky, important and/or used in many
different places, I prefer proper function comments.  There really is
no reason not to do it.

Thanks.

-- 
tejun
