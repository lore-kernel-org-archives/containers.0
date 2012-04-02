From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: [PATCHSET] block: modularize blkcg config and stat file handling
Date: Mon, 02 Apr 2012 14:51:14 -0700
Message-ID: <4F7A1F52.50706@kernel.dk>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
	<4F741AED.6090901@kernel.dk>
	<20120402200233.GB17175@dhcp-172-17-108-109.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120402200233.GB17175-RcKxWJ4Cfj1J2suj2OqeGauc2jM2gXBXkQQo+JxHRPFibQn6LdNjmg@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012-04-02 13:02, Tejun Heo wrote:
> Hey, Jens.
> 
> On Thu, Mar 29, 2012 at 10:18:53AM +0200, Jens Axboe wrote:
>> The diffstat is very tasty... I'll leave this on out until the cgroup
>> merge mess is settled, though.
> 
> The following branch contains this patchset on top of the current
> block/for-3.5/core 959d851caa "Merge branch 'for-3.5' of ../cgroup
> into block/for-3.5/core-merged".
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git blkcg-files
> 
> Other than $SUBJ update on the eigth patch from "blkcg:
> blkg_conf_prep()" to "blkcg: simplify blkg_conf_prep()", the patchset
> can be applied as-is on top of the current block/for-3.5/core.

Alright, pulled in as well. I'm glad we pushed this to 3.5 :-)

-- 
Jens Axboe
