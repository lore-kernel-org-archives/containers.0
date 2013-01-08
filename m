From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/24] cfq-iosched: add leaf_weight
Date: Tue, 8 Jan 2013 10:34:48 -0500
Message-ID: <20130108153448.GB29635@redhat.com>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-12-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1356726946-26037-12-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 28, 2012 at 12:35:33PM -0800, Tejun Heo wrote:

[..]
> +
> +	/* on root, leaf_weight is mapped to weight */
> +	{
> +		.name = "leaf_weight_device",
> +		.flags = CFTYPE_ONLY_ON_ROOT,
> +		.read_seq_string = cfqg_print_weight_device,
> +		.write_string = cfqg_set_weight_device,
> +		.max_write_len = 256,
> +	},
> +	{
> +		.name = "leaf_weight",
> +		.flags = CFTYPE_ONLY_ON_ROOT,
> +		.read_seq_string = cfq_print_weight,
> +		.write_u64 = cfq_set_weight,
> +	},

Hi Tejun,

How does it help to map leaf weight to weight in root group. Old programs
anyway don't know about leaf_weight. So nobody is going to update it. And
if they update it, they better know what does it do.

I think we just need to map "weight" to "leaf_weight" once you switch to
making use of leaf_weight and at that point of time a user will expect
that updating weight retains the old behavior. I think you have done
that in later patch.

But mapping leaf_weight to weight seems unnecessary atleast from backward
compatibility point of view.

Thanks
Vivek
