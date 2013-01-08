From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH UPDATED 15/24] cfq-iosched: enable full blkcg hierarchy
	support
Date: Tue, 8 Jan 2013 09:42:40 -0500
Message-ID: <20130108144240.GA29635@redhat.com>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-16-git-send-email-tj@kernel.org>
	<20130107163405.GE3926@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130107163405.GE3926-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jan 07, 2013 at 08:34:05AM -0800, Tejun Heo wrote:

[..]
> +        weight leaf_weight
> + root :  125    125
> + A    :  500    750
> + B    :  250    500
> + AA   :  500    500
> + AB   : 1000    500
> +
> +root never has a parent making its weight is meaningless. For backward
> +compatibility, weight is always kept in sync with leaf_weight. B, AA
> +and AB have no child and thus its tasks have no children cgroup to
> +compete with. They always get 100% of what the cgroup won at the
> +parent level. Considering only the weights which matter, the hierarchy
> +looks like the following.
> +
> +          root
> +       /    |   \
> +      A     B    leaf
> +     500   250   125
> +   /  |  \
> +  AA  AB  leaf
> + 500 1000 750
> +
> +If all cgroups have active IOs and competing with each other, disk
> +time will be distributed like the following.
> +
> +Distribution below root. The total active weight at this level is
> +A:500 + B:250 + C:125 = 875.
> +
> + root-leaf :   125 /  875      =~ 14%
> + A         :   500 /  875      =~ 57%
> + B(-leaf)  :   250 /  875      =~ 28%
> +
> +A has children and further distributes its 57% among the children and
> +the implicit leaf node. The total active weight at this level is
> +AA:500 + AB:1000 + A-leaf:750 = 2250.
> +
> + A-leaf    : ( 750 / 2250) * A =~ 19%
> + AA(-leaf) : ( 500 / 2250) * A =~ 12%
> + AB(-leaf) : (1000 / 2250) * A =~ 25%

Hi Tejun,

What does (-leaf) is supposed to signify? I can understand that A-leaf
tells the share of A's tasks which are effectively in A-leaf group. 

Will just plain AA and AB be more clear?

Rest looks good to me. Thanks for updating the blkio-controoler.txt too.

Thanks
Vivek
