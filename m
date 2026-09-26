Received: from mail-pz2-f43.google.com (mail-pz2-f43.google.com [74.125.228.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7014C36F90C
	for <containers@lists.linux.dev>; Sat, 26 Sep 2026 07:21:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.43
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790407267; cv=pass; b=kv52gMPIQ/WpnUZpsNtiu0G/LAmrxMQ2f8pSudauaJhJj7dPhVdG+6CjHPboXFKsnn8/ci8S5GhmGekyWvVWeKf5HqAgSZOTRU01db/zsgCGdmA/L/C/UsXh2ziAUoAsrabRAxjfHDRQCg0aOX1VN/MxbKOPfTPE/E6nIQLydLU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790407267; c=relaxed/simple;
	bh=JSaZbVji5Ea0/OPC5PqKZgfN3e3cz3ZXBga9A0C+uKo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=o1SHXcqIyfTQK6RmL7P4A5Fj8mBTNmSNhPQkHFZvEXdNymc93QImBlxbraPkOe1MAJzWAy06loAen8WrwVFviYB82iZqohUall0KZ4edynUYgccMlsWTa9msCErStap46yyXJiJUuOJl+hwaA6yfjbuuwQREQJrVQFV/Ks4JklM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=FCEYVYwp; arc=pass smtp.client-ip=74.125.228.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FCEYVYwp"
Received: by mail-pz2-f43.google.com with SMTP id d2e1a72fcca58-85f0fc1fd8eso866918b3a.1
        for <containers@lists.linux.dev>; Sat, 26 Sep 2026 00:21:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790407266; cv=none;
        d=google.com; s=arc-20260327;
        b=KCnjXUfmChXpz7L1Cdie3Mw1mM+M1M3Lj3Jlva4F2OUXN4gD0CDXBHO6l6JAPfAYaP
         ZydeTWOhleNKKYC5gkwQh7AaNi2IoI6uESrSRUluiIO/pZCYLY5MrR0V/h/d5g5n0hWg
         cnqdP8zX5WAF249rQSK1Y7m6SXQKD49fFEiKgUt8DHlzQn+SPrh32e+gLxOkx/tr7nzC
         bUy4kFc7LM3l6TBRURXDuUH9PU6W/dDn3FcQqZM8B7MFfvC7W3IWegGtxvlhMDYmLmN1
         VyY/yz7vdgl47/jEYBE7lcNDpGtS2AkASSAWnUklf2JU/Tdyfex3qBPz6dYNqaU1bq4I
         2peA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=1fxaPqNTjN/pMftWjOpORDKiV+ubgNTjPPityCn5HVI=;
        fh=iGuuAT63ekqiMAchNgUod3YBs3gwurq7Yr9uqbQhudk=;
        b=ol7zLckNdyU8oP+zGMeroWQQcZqsBYDTV1Kt4WFVPePT/KWzv5C2UZYjehseAraHT0
         XR2CRyJtq+RIEjFrNBjmXuLE2aeeK1SReN3WRYauUWYrJfewGl/WVJaMqx2qqYEQJB7F
         p0qOVt+BWz6uliWlsL6LJwRu7ZxP7RQMi6X5X/SJDmHx8PO39ir110eYNxe2v8+jGXQe
         u7qC1+NDJ7EAuMr+H2LnP45L4Q7TmseFuNYWPZ77oLiChE28PV2NmEqjzBBHOjyh1d/w
         qPb3hF6APvHGikujsEGnAxF+3aQbvbh1XsxO6sB2/q0FseQ+SzKVr+VDC90UQmAf60kZ
         KVgw==;
        darn=lists.linux.dev
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790407266; x=1791012066; darn=lists.linux.dev;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=1fxaPqNTjN/pMftWjOpORDKiV+ubgNTjPPityCn5HVI=;
        b=FCEYVYwpHiJHCt1kVol3p4bDqQqPHFN4mxTmigjI63VomtFByYFTzNAJQqzG414RzB
         slznWZ2yF/S1RRe790e4ohed2bu5CGwXC1iiMn4PZmv8AzD86fyj5a6elrvnBSQg+sVf
         7Woxr+327mHv+aAg8oi5H20mX9eykS1hzuyjfChIegP/kOpl6II5tvqibkvMNNPr6vJZ
         weyPoQ0xrQJabs5OpTRcdEBL5lAEA8QY3Y98jRP3lnHQKUFghTIg47mlHzSOygYqGdhY
         kOlkLsVOVNp/pGOgXiYNnHwWTKQ3eu64LhxT8XNNN3DCWnBujc7eacYns7v9w6V46nCg
         0Kaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790407266; x=1791012066;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=1fxaPqNTjN/pMftWjOpORDKiV+ubgNTjPPityCn5HVI=;
        b=BaRdX3vE+rUoEbARYB7uATpWOiF+DTbItqU01sA5dhbeIdo4qRw4gDlkDQam3OKuFt
         Qk1K0uYEKCey52F3bbb34IVUP6z5eeF+9gbivxpCGI6lvpCg7KGeqlOP6ey7V84YdZ2N
         rOnmNRJ2f9KT8au8KJQZV84M7jn0B3LiuQm3/HbmJ/QlaGoh3c3dgKifgVI5KURzl7Ue
         VZkFXllZH+8GUA4ImHw0sfWaaZhRKqQtr89u/R1IbWDNpsFoYwvGttLyK0xR/2+at+Yl
         IiuRa1Zmg6x7sQwnPEOJ60WhMZlQ6EA1viIEmi2CGchr8w6xvGlA74JRD0MmOA+HpFm9
         FSNg==
X-Forwarded-Encrypted: i=1; AKwUvBy2I99YqjL+F6nt4l/suKyEWKzxg9THled2Yos47OsGbn/aGi2bEBul4cAtEpf6v3feC9KmRga198Ws@lists.linux.dev
X-Gm-Message-State: AFuF++kOpypk6olTuufkJutnv0NHEugMPjxH/lytIGtOr8ooKjOosovx
	lBd3/us8k4lzQsuXBOjA47ohH2p5eR/HT9RTkhjbICU9zlLOqo+q80uHx8CHjrLJMLrJ40MaWEO
	Tvri0VOZl/3BwhEklLFWhKqMyJ2BMGlA=
X-Gm-Gg: AYBFou1zmOihkijMhvIseug82GFAsR8Tfr6zP+/bCirpjbxWx992htZpiBSMXM5RFFL
	C07ozgmYuef0bXkJvXHKk46y/lnDyhC2fQAPTWXOyjk+lxVTW6CeFtDzCu9yBNOe/zScFgL9bsr
	a2gltPF1CTeNNY/kx3DUYakByflHgJ5CI+XOtMaFjOp1CRsPPWQikD7kY0gXJH8dH7v1FKpi8vV
	N7lVjIK6dWE+vtsmSzZXabDiVK5pmjgo61cpXtlAgQC44YbAqOJN1ajf3Ic2iYw5RaghEmHp6KH
	unq/lxQDiNnrqUnUVXMcwRBW0ySvE2MqtCPi3zVOdUn2LqRPIhGd9kU=
X-Received: by 2002:a05:6a20:a11d:b0:3d7:dfbf:7435 with SMTP id
 adf61e73a8af0-3de0e6cda41mr7552780637.25.1790407265676; Sat, 26 Sep 2026
 00:21:05 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20260923205028.711077-1-kolyshkin@gmail.com> <20260925-zugnummer-intolerant-unwahr-2cddd52e435c@brauner>
In-Reply-To: <20260925-zugnummer-intolerant-unwahr-2cddd52e435c@brauner>
From: Kirill Kolyshkin <kolyshkin@gmail.com>
Date: Sat, 26 Sep 2026 00:20:54 -0700
X-Gm-Features: AclHuK8CjebxrGLaeQF03zgqQYXxG7Ana61oRaZrCBoCqp-gd9qKzgfSLqEq9J4
Message-ID: <CAGmPdryJ32KFtJiX3X+3X_9Fkesj=9GHjPN2qm3H_ctd4Z0bdg@mail.gmail.com>
Subject: Re: [RFC PATCH] mount: add OPEN_TREE_SKIP_MNTNS
To: Christian Brauner <brauner@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Aleksa Sarai <cyphar@cyphar.com>, Jan Kara <jack@suse.cz>, 
	Jeff Layton <jlayton@kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, 
	David Howells <dhowells@redhat.com>, Amir Goldstein <amir73il@gmail.com>, 
	Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
	Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 25, 2026 at 6:45=E2=80=AFAM Christian Brauner <brauner@kernel.o=
rg> wrote:
>
> On Wed, Sep 23, 2026 at 01:50:25PM -0700, Kir Kolyshkin wrote:
> > crun, a container runtime, recently started using OPEN_TREE_NAMESPACE t=
o
> > set up the container's mount namespace, and open_tree(OPEN_TREE_CLONE)
> > for the sources of its bind mounts.  This turns out not to work on host=
s
> > that have a mount namespace pinned anywhere below such a source: the
> > recursive clone picks the pinned namespace up, and move_mount(2) then
> > refuses to attach the tree with ELOOP from check_for_nsfs_mounts().
> > This was reported to crun in [1].
>
> Yeah, I think that makes sense. Please split this into two patches
> though: semantic changes separate from test changes. Maybe call it
> OPEN_TREE_DROP_MNTNS_MOUNTS instead?

Thanks! Done in v2:
https://lore.kernel.org/r/20260926-nsfs-prune-rfc-v2-0-53509260e4e7@gmail.c=
om
