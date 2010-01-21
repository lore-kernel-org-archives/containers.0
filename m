From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] C/R: Basic support for network namespaces and devices
Date: Thu, 21 Jan 2010 07:37:52 -0800
Message-ID: <87fx5zpiy7.fsf@caffeine.danplanet.com>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
	<1263999673-11279-4-git-send-email-danms@us.ibm.com>
	<4B5781DF.6050106@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B5781DF.6050106-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Wed\,
	20 Jan 2010 17\:21\:19 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

BH> What about:

BH>     1. Multicast
BH>     2. Device config info (ipv4_devconf)

<snip>

BH> What about addr->ifa_flags and all the other elements like
BH> prefixlen, scope and label?

I thought I was covered by calling it "Basic support..." :)

I've added these to the list of TODOs and will cook those up once the
basic bits are in.

>> +	if ((ret >= 0) && (ret != h->inet4_addrs)) {
>> +		ret = -EBUSY;
>> +		ckpt_err(ctx, ret,
>> +			 "Addresses on interface %s changed\n", dev->name);
>> +		goto out;
>> +	}

BH> This isn't guaranteed to catch every change to the address list,
BH> just that the number of addresses is the same, is there no way to
BH> hold a lock the whole time?

Yeah, there probably is.  I'll take a look.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
