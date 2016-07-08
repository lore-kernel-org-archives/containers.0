From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 3/4] userns/inotify: Initial implementation of inotify
	per-userns
Date: Fri, 08 Jul 2016 10:08:24 -0500
Message-ID: <87furkupzr.fsf@x220.int.ebiederm.org>
References: <1467207425-22072-1-git-send-email-kernel@kyup.com>
	<1467207425-22072-4-git-send-email-kernel@kyup.com>
	<87mvluekun.fsf@x220.int.ebiederm.org> <577E5BC2.1000208@kyup.com>
	<87inwh31v6.fsf@x220.int.ebiederm.org> <577F91C9.9060903@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <577F91C9.9060903-6AxghH7DbtA@public.gmane.org> (Nikolay Borisov's message of "Fri, 8
	Jul 2016 14:43:05 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> Having started writing the code I just realized it's possible that 2
> uids in different namespaces map to the same KUID, depending on how the
> UID map is setup, right? If that's the case then I guess it will make
> sense to actually hold kuid + userns pointer in nsuser_state to be able
> to distinguish between the state of kuid 1500 in userns1 and kuid1500 in
> userns2. Does that make sense?

Yes, very much so.

Especially in nested user namespaces this is not only possible but
required.

Eric
