From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 16/23] cgroup: relocate cgroup_advance_iter()
Date: Fri, 2 Aug 2013 15:35:56 -0400
Message-ID: <20130802193556.GB29736__2.13289536095118$1375472170$gmane$org@mtj.dyndns.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
	<1375393801-4817-17-git-send-email-tj@kernel.org>
	<51FB26C6.2020100@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51FB26C6.2020100-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Li.

On Fri, Aug 02, 2013 at 11:25:58AM +0800, Li Zefan wrote:
> On 2013/8/2 5:49, Tejun Heo wrote:
> > For some reason, cgroup_advance_iter() is standing lonely all away
> > from its iter comrades.  Relocate it.
> > 
> 
> There're some other functions that are in the same situation. Do you
> think it's better to relocate them, or just leave it as it is?

Hmm... I really don't wanna do one huge reorganize-everything patch as
they tend to be difficult to verify and the disturbance to benefit
ration usually isn't that high, but if the respective part of code is
going through changes and thus will be disturbed anyway, I think it
makes sense to reorganize a bit.

Thanks.

-- 
tejun
