From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: net 2.6.25
Date: Wed, 14 Nov 2007 13:07:04 +0300
Message-ID: <473AC8C8.6070307@sw.ru>
References: <473AC169.1030202@sw.ru> <m1ve8517dd.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ve8517dd.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Will you be happy, if I'll re-merge all of them from scratch preserving
original subjects from the letters?

Regards,
	Den

Eric W. Biederman wrote:
> "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:
> 
>> Hello, guys!
>>
>> David has been opened net-2.6.25 tree yesterday, so we could send a new
>> portion of NETNS there. If there are no objections, I'll send first six
>> patches from OpenVZ GIT tomorrow, i.e. RTNL infrastructure, Packet &
>> Unix sockets virtualization + some our /proc cleanups.
> 
> I think I can pretty much agree on that set of patches.  However I do strongly
> object to the form they are in at: http://git.openvz.org/?p=linux-2.6-netns
> 
> All of my subject lines (which are the primary summary of the patch) have
> been lost.  So it is much more difficult to see what the patch is doing.
> 
> I will get some sleep and see what I can sort out.
> 
> Eric
> 
