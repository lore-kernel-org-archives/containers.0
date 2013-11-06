From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 02/10] netfilter: nf_log: prepar net namespace support
	for nf_log
Date: Wed, 06 Nov 2013 10:00:04 +0800
Message-ID: <5279A2A4.9060405__25733.0731642016$1383703164$gmane$org@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1360223390-15589-2-git-send-email-gaofeng@cn.fujitsu.com>
	<20131105141455.GB22912@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131105141455.GB22912-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lve-ke3WRBg/xIg@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/05/2013 10:14 PM, Arnaldo Carvalho de Melo wrote:
> Em Thu, Feb 07, 2013 at 03:49:42PM +0800, Gao feng escreveu:
>> index 9e31269..b1e5126 100644
>> +++ b/net/netfilter/nf_log.c
>> @@ -16,7 +16,6 @@
>>  #define NF_LOG_PREFIXLEN		128
>>  #define NFLOGGER_NAME_LEN		64
>>  
>> -static const struct nf_logger __rcu *nf_loggers[NFPROTO_NUMPROTO] __read_mostly;
> 
> This was initialized to zeros, but then got moved to struct netns_nf,
> I'm trying to figure it out if it is being zeroed somewhere, ideas?
> 

The init_net is defined as global, so the nf_loggers of init_net is initialized to zero,
and for un init_net, we use kmem_cache_zalloc to allocate net struct, so it is initialized to zero too.
