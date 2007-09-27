From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [patch 2/3][NETNS45][V2] make timewait unhash lock free
Date: Thu, 27 Sep 2007 17:18:54 +0400
Message-ID: <46FBADBE.9080400@sw.ru>
References: <20070927110400.409277229@mai.toulouse-stg.fr.ibm.com>
	<20070927111212.651097600@mai.toulouse-stg.fr.ibm.com>
	<46FBA624.2070203@sw.ru> <46FBAB6C.6010908@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46FBAB6C.6010908-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> [ cut ]
>>> +
>>>> see above about inet_twsk_unehash. We should insert
>>         /* Disassociate with bind bucket. */
>>>> here
>>> +    return 0;
>>> +}
> 
> Is this comment for me ?
> 

yes. It will be dropped in the upper part of the code and have to be
inserted here instead
