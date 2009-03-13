From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Fri, 13 Mar 2009 17:04:53 +0100
Message-ID: <49BA8425.9020005@free.fr>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>	<20090312162954.4a4b8e00@thinkcentre.lan>	<87fxhipfrh.fsf@caffeine.danplanet.com>
	<49B99144.9000106@free.fr>	<877i2upcvo.fsf@caffeine.danplanet.com>
	<49B996BC.1090908@free.fr> <873adipc5l.fsf@caffeine.danplanet.com>
	<49BA82CE.4090206@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49BA82CE.4090206-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Cedric Le Goater wrote:
> Dan Smith wrote:
>   
>> DL> I guess it will be esay to implement with a nsproxy level counter.
>> DL> Each time you unshare, the new nsproxy count is incremented.
>> DL> Assuming the init_nsproxy is level 0, when the nsproxy counter is
>> DL> > 1, the process is uncheckpointable.
>>
>> This should also be possible by just making sure that the nsproxy of
>> the root process being checkpointed is the same as any of the
>> children, correct?  That way we avoid having to modify the core
>> nsproxy bits and can still reject any nested namespaces.
>>     
>
> Daniel L, could we cleanup the patch we have on ns_group which filters
> out the clone() done with the 'wrong' clone flags ? 
>
> Thanks,
>   
Sure.
