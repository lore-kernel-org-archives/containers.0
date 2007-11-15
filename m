From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 1/1][NETNS] fix fib_frontend compilation error
Date: Thu, 15 Nov 2007 06:31:18 -0700
Message-ID: <m1oddvy6s9.fsf@ebiederm.dsl.xmission.com>
References: <20071114142443.794857293@mai.toulouse-stg.fr.ibm.com>
	<20071114142523.283777897@mai.toulouse-stg.fr.ibm.com>
	<473B1F63.5040105@sw.ru> <473B1FC2.9030003@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <473B1FC2.9030003-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message of "Wed,
	14 Nov 2007 17:18:10 +0100")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> Denis V. Lunev wrote:
>> applied... though I am not too familiar with git and the author has been
>> set to me rather than you with your signed-off :(
>
> It's ok :)
>
> I think you should specify the --author option when commiting.

My normal technique here is to simply save the entire email message
and then do git-am email.txt and git picks it all up from the
headers.

Eric
