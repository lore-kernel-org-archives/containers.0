From: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [PATCH 14/15] Destroy pid namespace on init's death
Date: Thu, 02 Aug 2007 12:37:55 +0400
Message-ID: <46B197E3.3040309@sw.ru>
References: <46A8B37B.6050108@openvz.org>
	<46A8B663.9040206@openvz.org>	<20070729104145.GC120@tv-sign.ru>
	<46ADD202.9030502@openvz.org>	<20070730154639.GA127@tv-sign.ru>	<20070731061917.GB17013@us.ibm.com>	<20070731090721.GA110@tv-sign.ru>	<20070801061616.GA5405@us.ibm.com>	<1185984030.18414.234.camel@localhost>
	<20070801195123.GB196@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070801195123.GB196-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov wrote:
> On 08/01, Dave Hansen wrote:
> 
>>>	If the main thread is exiting, but is not the last thread in the
>>>	group, should we let it exit and let the next thread in the group
>>>	the reaper of the pid ns ?
>>
>>Well, what happens with a multithreaded init today?
> 
> 
> As it was already discussed, the current code is buggy, and should be
> fixed.

I'm not that sure it MUST be fixed. There are no multi-threaded init's anywhere.
Oleg, does it worth changing without reasons?

Thanks,
Kirill
