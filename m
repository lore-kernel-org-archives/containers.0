Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E26B7A
	for <containers@lists.linux.dev>; Wed, 23 Feb 2022 00:27:53 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52]:34536)
	by out02.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nMf5P-00Gru7-Fr; Tue, 22 Feb 2022 17:00:51 -0700
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:51350 helo=email.froward.int.ebiederm.org.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nMf5N-00G58W-IT; Tue, 22 Feb 2022 17:00:50 -0700
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: xu xin <cgel.zte@gmail.com>
Cc: bsingharora@gmail.com,  akpm@linux-foundation.org,
 deng.changcheng@zte.com.cn,  linux-kernel@vger.kernel.org,
 balbir@linux.vnet.ibm.com,  xu.xin16@zte.com.cn,
 Linux Containers <containers@lists.linux.dev> 
References: <20220217093945.1904085-1-xu.xin16@zte.com.cn>
	<20220221032202.1925507-1-xu.xin16@zte.com.cn>
Date: Tue, 22 Feb 2022 18:00:42 -0600
In-Reply-To: <20220221032202.1925507-1-xu.xin16@zte.com.cn> (xu xin's message
	of "Mon, 21 Feb 2022 03:22:02 +0000")
Message-ID: <87v8x678ph.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1nMf5N-00G58W-IT;;;mid=<87v8x678ph.fsf@email.froward.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX19QOxAXvj0mBgOUQkTk4AIyjG4Lz6zcAgQ=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=-0.3 required=8.0 tests=ALL_TRUSTED,BAYES_40,
	DCC_CHECK_NEGATIVE,T_SCC_BODY_TEXT_LINE,T_TM2_M_HEADER_IN_MSG,
	XMSubLong autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	* -0.0 BAYES_40 BODY: Bayes spam probability is 20 to 40%
	*      [score: 0.3778]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;xu xin <cgel.zte@gmail.com>
X-Spam-Relay-Country: 
X-Spam-Timing: total 1208 ms - load_scoreonly_sql: 0.16 (0.0%),
	signal_user_changed: 13 (1.1%), b_tie_ro: 11 (0.9%), parse: 1.50
	(0.1%), extract_message_metadata: 20 (1.6%), get_uri_detail_list: 2.6
	(0.2%), tests_pri_-1000: 8 (0.7%), tests_pri_-950: 1.80 (0.1%),
	tests_pri_-900: 1.53 (0.1%), tests_pri_-90: 184 (15.2%), check_bayes:
	180 (14.9%), b_tokenize: 14 (1.2%), b_tok_get_all: 9 (0.8%),
	b_comp_prob: 3.8 (0.3%), b_tok_touch_all: 149 (12.4%), b_finish: 1.12
	(0.1%), tests_pri_0: 478 (39.6%), check_dkim_signature: 0.73 (0.1%),
	check_dkim_adsp: 3.8 (0.3%), poll_dns_idle: 465 (38.5%), tests_pri_10:
	3.4 (0.3%), tests_pri_500: 491 (40.6%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH resend] kernel: Make taskstats available via genetlink
 per namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

xu xin <cgel.zte@gmail.com> writes:

> Currently, the application getdelays cannot get taskstats in a net
> namespace. The returned error is just like the following:
> -sh-4.4# ps -ef | tail -5
> root       186     2  0 09:23 ?        00:00:00 [kworker/2:1H]
> root       187     2  0 09:23 ?        00:00:00 [kworker/0:2-eve]
> root       190   183  0 09:23 ?        00:00:00 -sh
> root       198   190  0 09:25 ?        00:00:00 ps -ef
> root       199   190  0 09:25 ?        00:00:00 tail -5
> -sh-4.4#
> -sh-4.4# ./getdelays -d -p 186 -v
> print delayacct stats ON
> debug on
> Error getting family id, errno 0
>
> As more and more applications are deployed in containers like Docker,
> it is necessary to support getdelays to be used in net namespace.
> Taskstats is safe for use per namespace as genetlink checks the
> capability of namespace message by netlink_ns_capable().
>
> Make taskstats available via genetlink per namespace.

Let me add a polite nack to this patch.

Taskstats is completely senseless in a network namespace.  There is no
translation of identifiers into the context of the receiver of the
message.

As such taskstats can not be meaningfully used in a container.

To make this work requires updating the taskstats code to do something
sensible when in a pid namespace, as well as when in a network
namespace.

I would like to give a suggest on how to do something sensible but
I don't have any idea at this point.  The code would have been converted
long ago on general principles if this was a straight forward thing to
do.

The taskstats interface only makes sense when you are within all of the
initial namespaces.

Eric

> Reported-by: Changcheng Deng <deng.changcheng@zte.com.cn>
> Signed-off-by: xu xin <xu.xin16@zte.com.cn>
> ---
>  kernel/taskstats.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/kernel/taskstats.c b/kernel/taskstats.c
> index 2b4898b4752e..4d6bcaaf52a0 100644
> --- a/kernel/taskstats.c
> +++ b/kernel/taskstats.c
> @@ -664,6 +664,7 @@ static struct genl_family family __ro_after_init = {
>  	.module		= THIS_MODULE,
>  	.ops		= taskstats_ops,
>  	.n_ops		= ARRAY_SIZE(taskstats_ops),
> +	.netnsok	= true,
>  };
>  
>  /* Needed early in initialization */
