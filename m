From: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Device Namespaces
Date: Tue, 1 Oct 2013 21:23:51 +0300
Message-ID: <CAE=NcraK9FN2WFLcfxNNBVuWAyX5TE50+H_dQDWWEeJRc_KCzw@mail.gmail.com>
References: <20130822182118.GA28331@sergelap>
	<CAA4jN2YL7Lfu2+DW-i+MovFxWEhJfT4aBBKREU_vy7JX9TKGHA@mail.gmail.com>
	<8761udlu0d.fsf@xmission.com>
	<CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com> <20130926053320.GB3725@kroah.com>
	<CAE=NcrYV2RiMV7PcwEjFGFRBrz9XdZGs86Wau2a+6xpYN2aEHA@mail.gmail.com>
	<20131001173342.GA19267@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131001173342.GA19267-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, devel <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 1, 2013 at 8:33 PM, Greg Kroah-Hartman
<gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> wrote:

>> > That's right, they should be listening to libudev events, so why can't
>> > your daemon shuffle them off to the proper container, all in userspace?
>>
>> Which reminds me, one potential reason being..
>> http://lists.linuxfoundation.org/pipermail/containers/2013-May/032591.html
>
> I really wish I had never seen that patch, and I am glad it was
> rejected.

Thanks, I agree. Just wanted to point out the reason and
bring up the discussion.


-- 
Janne
