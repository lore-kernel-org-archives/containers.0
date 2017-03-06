From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH] ucount: Remove the atomicity from ucount->count
Date: Mon, 06 Mar 2017 15:26:09 -0600
Message-ID: <87fuiq14i6.fsf@xmission.com>
References: <CACT4Y+a043_qFN=2uzvYhDFwF4JS9_p3jnOykpMk=RcpqQfKGQ@mail.gmail.com>
	<CACT4Y+Yev63VXYm+kZdii5kheV_ACBn2cehFcFdz6LBVam3Q2g@mail.gmail.com>
	<CACT4Y+b7YXnoOkdYTjp6D6XH-zuYRx063hMayOVMyJVc735dtQ@mail.gmail.com>
	<c69f8f03-4324-f934-eed2-643c91d703c0@gmail.com>
	<CACT4Y+avCy8Susvb09DLHkGym0K_15+EeZ8yBH7tcgjvnb3Yhw@mail.gmail.com>
	<CACT4Y+YWEq66QXbTMR4yGtgc0ULN+TurAnRzcDASaja1z5XNjA@mail.gmail.com>
	<87shmsoar7.fsf@xmission.com>
	<CACT4Y+bYAbsxsRWA2o+c7x25f1JPSqZKX-8a8NJq4nab-PyYig@mail.gmail.com>
	<87y3wjlg6r.fsf@xmission.com> <87tw77csgd.fsf_-_@xmission.com>
	<20170306203919.GA17874@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170306203919.GA17874-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Andrei Vagin's message of
	"Mon, 6 Mar 2017 12:39:21 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, JongHwan Kim <zzoru007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Sun, Mar 05, 2017 at 03:41:06PM -0600, Eric W. Biederman wrote:
>> 
>> Always increment/decrement ucount->count under the ucounts_lock.  The
>> increments are there already and moving the decrements there means the
>> locking logic of the code is simpler.  This simplification in the
>> locking logic fixes a race between put_ucounts and get_ucounts that
>> could result in a use-after-free because the count could go zero then
>> be found by get_ucounts and then be freed by put_ucounts.
>> 
>> A bug presumably this one was found by a combination of syzkaller and
>> KASAN.  JongWhan Kim reported the syzkaller failure and Dmitry Vyukov
>> spotted the race in the code.
>>
>
> Reviewed-by: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> I think we can rework this in a future so that ucount will be rcu
> protected.

Agreed. Although I would like to see a benchmark that motivated that.
So far my impression is that all of these counts are in the noise.
Which is why I have aimed more at simplicity than the fastest possible
data structures.


Eric
