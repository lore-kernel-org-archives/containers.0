From: Raghavendra K T <raghavendra.kt-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 12/12] cgroup: implement dynamic subtree controller
	enable/disable on the default hierarchy
Date: Mon, 21 Apr 2014 13:47:38 +0530
Message-ID: <5354D422.8010606@linux.vnet.ibm.com>
References: <1397511430-2673-1-git-send-email-tj@kernel.org>
	<1397511430-2673-13-git-send-email-tj@kernel.org>
	<CAC4Lta0tD=FbtVpGnLw2sKMY69+AnqYqaOvCQdFs88JeR5Pemw@mail.gmail.com>
	<20140418204108.GL23576@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140418204108.GL23576-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 04/19/2014 02:11 AM, Tejun Heo wrote:
> Hello,
>
> On Thu, Apr 17, 2014 at 11:33:50PM +0530, Raghavendra KT wrote:
>> On Tue, Apr 15, 2014 at 3:07 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>> I undertsand that with the above parsing we could do
>> echo "-blkio +blkio" > cgroup.subtree_control and honor last enable/disable.
>
> Yeah, and the behavior is described in the following document.
>

Hello Tejun, Thanks for the kind reply. The document has helped me a
lot while reviewing,testing the unified hierarchy code.

>   http://lkml.kernel.org/g/20140416145248.GD1257-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org
>
>> It confused me while testing. do you think we should return -EINVAL in
>> such case?
>
> Hmmm... I think whatever comes later wins is a pretty clear and easy
> rule, no?

Very much correct. and if there is a feeling to check multiple entry
later I would happy to update the code.
