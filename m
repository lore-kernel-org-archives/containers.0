From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 04/11] Add backend support for suboridnate uids and gids
Date: Thu, 24 Jan 2013 14:42:49 -0800
Message-ID: <87a9ryyzh2.fsf@xmission.com>
References: <87d2wxshu0.fsf@xmission.com> <87liblr344.fsf@xmission.com>
	<20130123182206.GA4468@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130123182206.GA4468-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 23 Jan 2013 18:22:06 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?utf-8?Q?Fran=C3=A7ois?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> +static void *subordinate_parse (const char *line)
>> +{
>> +	static struct subordinate_range range;
>> +	char rangebuf[1024];
>> +	int i;
>> +	char *cp;
>> +	char *fields[NFIELDS];
>> +
>> +	/*
>> +	 * Copy the string to a temporary buffer so the substrings can
>> +	 * be modified to be NULL terminated.
>> +	 */
>> +	if (strlen (line) >= sizeof rangebuf)
>> +		return NULL;	/* fail if too long */
>> +	strcpy (rangebuf, line);
>> +
>> +	/*
>> +	 * Save a pointer to the start of each colon separated
>> +	 * field.  The fields are converted into NUL terminated strings.
>> +	 */
>> +
>> +	for (cp = rangebuf, i = 0; (i < NFIELDS) && (NULL != cp); i++) {
>> +		fields[i] = cp;
>> +		while (('\0' != *cp) && (':' != *cp)) {
>> +			cp++;
>> +		}
>> +
>> +		if ('\0' != *cp) {
>> +			*cp = '\0';
>> +			cp++;
>> +		} else {
>> +			cp = NULL;
>> +		}
>> +	}
>> +
>> +	/*
>> +	 * There must be exactly NFIELDS colon separated fields or
>> +	 * the entry is invalid.  Also, fields must be non-blank.
>> +	 */
>> +	if (i != NFIELDS || *fields[0] == '\0' || *fields[1] == '\0' || *fields[2] == '\0')
>> +		return NULL;
>> +	range.owner = fields[0];
>> +	if (getulong (fields[1], &range.start) == 0)
>> +		return NULL;
>> +	if (getulong (fields[2], &range.count) == 0)
>> +		return NULL;
>> +
>> +	return &range;
>
> This function worries me, because you're returning local contents (both range
> itself, and range.owner).

In practice that function is fine, and is mostly in the style of the
other functions that implement parse.  As parse is expected to return
a reference to a statically allocated buffer.

Furthermore the only use in commonio.c is to do:
	if (NULL != parse(...))
        	dup(...)

But it does look like when I made the user name a string I did deviate
from the norm and have failed to copy the string to a statically
allocated buffer.

In practice it doesn't matter but it looks worth fixing for the sake of
long term maintenance.

Eric
