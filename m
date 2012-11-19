From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 2/3] netcls_cgroup: introduce cgroup_cls_state->is_local
Date: Mon, 19 Nov 2012 13:54:26 +0100
Message-ID: <50AA2C02.1000702__11682.0013536655$1353329690$gmane$org@monom.org>
References: <1353123062-23193-1-git-send-email-tj@kernel.org>
	<1353123062-23193-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353123062-23193-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Tejun,

On 17.11.2012 04:31, Tejun Heo wrote:
> -static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
> +static int write_classid(struct cgroup *cgrp, struct cftype *cft,
> +			 const char *buf)
>   {
> +	struct cgroup_cls_state *cs = cgrp_cls_state(cgrp);
> +	s64 v;
> +
> +	if (sscanf(buf, "%lld", &v) != 1)
> +		return -EINVAL;
> +

This changes the user API slightly. cgroup_write_u64() uses 
simple_stroull() to parse the string. simple_stroull() allows to use 
either 0x1234 or 1234 as input. sscanf() will only handle the later type 
of input.

I noticed this because my test script stopped working:

    mkdir /sys/fs/cgroup/net_cls/a
    echo 0x100002 > /sys/fs/cgroup/net_cls/a/net_cls.classid # 10:2

    tc qdisc add dev $DEV root handle 10: htb
    tc class add dev $DEV parent 10: classid 10:2 htb rate 1mbit
    tc qdisc add dev $DEV parent 10:2 handle 20: sfq perturb 10

I am not completely sure if my setup is 100% correct, but at least
it seems to make something :)

cheers,
daniel
