From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [RFC] [PATCH] memory controller background reclamation
Date: Tue, 27 Nov 2007 07:43:58 +0900 (JST)
Message-ID: <20071126224359.2268C1CF696@siro.lan>
References: <474A43D5.8020600@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Mon, 26 Nov 2007 09:26:05 +0530"
	<474A43D5.8020600-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, minoura-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
List-Id: containers.vger.kernel.org

> Balbir Singh wrote:
> > YAMAMOTO Takashi wrote:
> >>>> +	int batch_count = 128; /* XXX arbitrary */
> >>> Could we define and use something like MEM_CGROUP_BATCH_COUNT for now?
> >>> Later we could consider and see if it needs to be tunable. numbers are
> >>> hard to read in code.
> >> although i don't think it makes sense, i can do so if you prefer.
> >>
> > 
> > Using numbers like 128 make the code unreadable. I prefer something
> > like MEM_CGROUP_BATCH_COUNT since its more readable than 128. If we ever
> > propagate batch_count to other dependent functions, I'd much rather do
> > it with a well defined name.
> > 
> 
> I just checked we already have FORCE_UNCHARGE_BATCH, we could just
> rename and re-use it.

i don't think it's a good idea to use a single constant for
completely different things.

YAMAMOTO Takashi
