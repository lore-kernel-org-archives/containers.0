From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCHSET v2 cgroup/for-3.12] cgroup: make cgroup_event specific
	to memcg
Date: Mon, 26 Aug 2013 17:35:59 +0300
Message-ID: <20130826143559.GA15275@shutemov.name>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<20130826141536.GA14985@shutemov.name>
	<20130826151747.GD25171@htj.dyndns.org>
	<20130826142918.GB14985@shutemov.name>
	<20130826153028.GE25171@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130826153028.GE25171-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 26, 2013 at 11:30:28AM -0400, Tejun Heo wrote:
> Hello,
> 
> On Mon, Aug 26, 2013 at 05:29:18PM +0300, Kirill A. Shutemov wrote:
> > What about setting threshold itself? Do we a way to set it in inotify
> > interface or you have something else in mind?
> 
> Just have another file which configs the thresholds or sets the
> cadence?  The whole thing is overdesigned because it wants to allow
> individual listeners to have separate configurations which may be
> useful if access to sysfs hierarchy is open to everybody but that's
> not gonna be the case anymore and configuration of sysfs hierarchy is
> gonna be centralized anyway, so centralizing config of thresholds
> isn't any different from any other knobs.

Makes sense. Thank you.

Acked-by: Kirill A. Shutemov <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

-- 
 Kirill A. Shutemov
