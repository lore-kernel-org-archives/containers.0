From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
	cgroup core
Date: Thu, 6 Dec 2012 14:09:04 +0100
Message-ID: <20121206130904.GC10931@dhcp22.suse.cz>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
	<20121203152205.GB17093@dhcp22.suse.cz>
	<20121203165338.GF19802@htj.dyndns.org>
	<50C03A3F.7070605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50C03A3F.7070605-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu 06-12-12 14:25:03, Li Zefan wrote:
> On 2012/12/4 0:53, Tejun Heo wrote:
> > Hello, Michal.
> > 
> > On Mon, Dec 03, 2012 at 04:22:05PM +0100, Michal Hocko wrote:
> >> I have glanced through the series and spotten nothing obviously wrong. I
> >> do not feel I could give my r-b because I am not familiar with cpusets
> >> internals enough and some patches looks quite scary (like #8).
> >> Anyway the resulting outcome seems nice.
> > 
> > Thanks a lot for looking at it and, yeah, it's a bit scary.  Li, Paul,
> > can you guys please review the series?
> > 
> 
> We shoudn't haste to target this for 3.8, given that we're in late -rc and
> Michal felt some patches scary and they hasn't got enough review.

Well, even the original code is scary enough so if the decision should
be made just based on my feeling then it would be too sensitive
probably. Anyway I do agree that the series should see review from
others who are more familiar with the code before considering for
merging.
-- 
Michal Hocko
SUSE Labs
