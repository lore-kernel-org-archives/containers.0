From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [HELP] for using class group classifier network controller
Date: Thu, 18 Jun 2009 13:13:00 +0900
Message-ID: <20090618131300.14d575b8.usui__36533.1349931241$1245302109$gmane$org@mxm.nes.nec.co.jp>
References: <d89801c9ef32$cdfcf480$8310fe81@etri.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d89801c9ef32$cdfcf480$8310fe81-tRM8rG9f+DVhl2p70BpVqQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chei-Yol Kim <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
List-Id: containers.vger.kernel.org

> when I set the classid to 0x10010, class 1:10's packet count was increased. 
> But, according to your configuration, every packet has to flowed to 1:10 class. 

Yes, you are right.

> Of course I know that the net_cls can't classify all packet because of the getting classid from the current task. 
> Even though we consider it, Many packets are flowed to 1:30 class. 
> therefore, the rate of the socket showed about 30mbps. This is the 1:30 class's rate.
> I think it's because that 1:30 class is the default class. 
> When I changed the default to 20, the rate was varied to 20mbps, class 1:20's rate.
>
> 
> To measure this rate, I used the iperf and scp command. Two results are the same.
> How about your experiment's result? 
> Would you check the accurate rate of the network using applications like a iperf?

I did same experience with nuttcp, I observed the same result, too.
(Almost packets were classified into default classid.)
 
> By the results of my experiments, net_cls couldn't control the network rate of the group. 
> What is your opinion?

I agree with you.
I'm going to investigate this problem. 

-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
